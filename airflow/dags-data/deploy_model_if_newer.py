from airflow.decorators import dag, task
from airflow.sensors.python import PythonSensor
from mlflow.tracking import MlflowClient
import mlflow
import pendulum
import datetime
import traceback
import requests

mlflow.set_tracking_uri("http://mlflow-svc:5000")

MODEL_NAME = "Wine_Quality_Analysis_BestEstimator"
ALIAS = "champion"
DEPLOY_TAG_KEY = "deployed"

# MyNote: the DAG task runs every 1 minute.
def check_if_champion_is_new():
    client = MlflowClient()
    
    # 1. Find which version is currently the 'champion'
    try:
        mv = client.get_model_version_by_alias(MODEL_NAME, ALIAS)
    except Exception as e:
        print(f"Error occurred: {e}\n{traceback.print_exc()}")
        print(f"Alias '{ALIAS}' not found for model {MODEL_NAME}")
        return False

    # 2. Check if this specific version has been deployed yet
    # MLflow tags are a dictionary. We check if our key exists and is 'true'.
    is_deployed = mv.tags.get(DEPLOY_TAG_KEY) == "true"
    
    if not is_deployed:
        print(f"New champion detected! Version: {mv.version}. Proceeding to deploy.")
        return True
    
    print(f"Version {mv.version} is already deployed. Sleeping...")
    return False

@dag(dag_id="deploy_model_if_newer",
     schedule_interval='*/1 * * * *', # Every minute
     start_date=datetime.datetime(2024, 1, 1), 
     catchup=False, 
     max_active_runs=1,
     default_args={"retries": 1},
     is_paused_upon_creation=False)
def mlflow_tag_deployment_dag():

    # The Sensor: Stops the DAG here if the champion is already 'stamped' as deployed
    wait_for_new_model = PythonSensor(
        task_id="wait_for_new_model",
        python_callable=check_if_champion_is_new,
        poke_interval=15,  # Check every 15 seconds
        timeout=45,
        mode="reschedule"  # Recommended for long-running sensors
    )

    @task
    def deploy_and_stamp():
        client = MlflowClient()
        # Get the version currently marked as champion
        mv = client.get_model_version_by_alias(MODEL_NAME, ALIAS)
        
        print(f"Deploying model {MODEL_NAME} version {mv.version} to production...")
        
        url = "http://ml-app-svc:9696/update"

        data = {
            "model_name": MODEL_NAME,
            "model_alias": ALIAS
        }

        response = requests.post(url, json=data)
        
        if not (response.status_code == 200 and response.json()["status"] == "ok"):
            raise Exception(f"Error {response.status_code}: {response.text}")

        # Success! Now "stamp" the model in MLflow so the sensor ignores it next time
        client.set_model_version_tag(
            name=MODEL_NAME, 
            version=mv.version, 
            key=DEPLOY_TAG_KEY, 
            value="true"
        )
        print(f"Model version {mv.version} successfully tagged as deployed.")

    wait_for_new_model >> deploy_and_stamp()

mlflow_tag_deployment_dag()
