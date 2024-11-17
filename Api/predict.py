from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import uvicorn


app = FastAPI()


class InputData(BaseModel):
    Area: str  
    Item: str
    Year: int
    average_rain_fall_mm_per_year: float # (gt=0, lt=2000)  # Rainfall in mm, realistic range

    pesticides_tonnes: float
    avg_temp: float  ## t(gt=-30, lt=50)  # Temperature in Celsius, realistic range



# Load your pre-trained model
joblib_in = open("joblib_model.pkl","rb")
model = joblib.load("joblib_model.pkl")


# Define prediction route
@app.get('/')
def index():
    return {'message': 'Prediction input'}




@app.post("/predict")
def predict(data: InputData):
    # Prepare data for prediction
    input_data = [
        data.Area,
        data.Item,
        data.Year,
        data.average_rain_fall_mm_per_year,
        data.pesticides_tonnes,
        data.avg_temp
    ]
    # Make prediction
    prediction = model.predict([input_data])
    return {"predicted_yield": prediction[0]}

if __name__ == "__main__":

    uvicorn.run(app, host = '127.0.0.1', port = 8080)
