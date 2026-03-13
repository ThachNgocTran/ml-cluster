from flask import Flask, request, jsonify, render_template
import mlflow
import numpy as np

mlflow.set_tracking_uri("http://mlflow-svc:5000")
#mlflow.set_tracking_uri("http://mlflow.local")

app = Flask("ml_app")

# Placeholder for your Machine Learning Model
# In production, load this from a saved file (e.g., joblib or pickle)
model = None

@app.route("/", methods=["GET"])
def home():
    """
    Serves the web interface for users to interact with the model.
    """
    return render_template('index.html')

@app.route("/predict", methods=["POST"])
def predict():
    """
    Endpoint to perform inference using the loaded model.
    Expects JSON input.
    """
    try:
        if model is None:
            raise Exception("There is no Model.")
        
        data = request.get_json()
        if not data:
            raise Exception("No data provided.")
            
        if "input" not in data:
            raise Exception("No input field.")
        
        input_data = [float(x) for x in data["input"].split(",")]
        # Testing
        #input_data = [14.23, 1.71, 2.43, 15.6, 127.0, 2.8, 3.06, 0.28, 2.29, 5.64, 1.04, 3.92, 1065.0]
        
        if len(input_data) != 13:
            raise Exception(f"Need 13 features! But got {len(input_data)}.")
            
        input_array = np.array([input_data], dtype=np.float64)
        
        result = model.predict(input_array)   # should be 0, 1 or 2.
        res = {"status": "ok",
               "message": f"{result[0]}"}
    except Exception as e:
        res = {"status": "error",
               "message": f"{e}"}
               
    print(res)
    
    return jsonify(res)

@app.route("/update", methods=["POST"])
def update():
    """
    Endpoint to trigger a model update/reload.
    """
    global model

    try:
        model_name = request.json.get("model_name")
        model_alias = request.json.get("model_alias")
        
        # Load the specific version tagged with 'champion'
        model_uri = f"models:/{model_name}@{model_alias}"
        model = mlflow.pyfunc.load_model(model_uri)

        # Now you can use it for prediction
        # data = [[15.2, 2.0, 0.5]]
        # predictions = model.predict(data)
        
        res = {"status": "ok",
               "message": f"Updated Model: [{model_name}] @ [{model_alias}]"}
    except Exception as e:
        res = {"status": "error",
               "message": f"{e}"}
    
    print(res)
    
    return jsonify(res)

if __name__ == "__main__":
    # This is used for local debugging only. 
    # Gunicorn will ignore this and call 'app' directly.
    app.run(host="0.0.0.0", port=9696)
