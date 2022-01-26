from tensorflow.python.framework.config import set_visible_devices, get_visible_devices
from tensorflow.python.keras.backend import softmax, expand_dims
from tensorflow.lite.python.interpreter import Interpreter
from numpy import asarray, argmax
from pandas import read_csv
from requests import get
from io import BytesIO
from PIL import Image


def predict(inter, image):
    inter.set_tensor(input_details[0]['index'], expand_dims(asarray(image).astype('float32'), axis=0))
    inter.invoke()
    return softmax(inter.get_tensor(output_details[0]['index']))


CLASS_NAMES = ['hogweed', 'cetera', 'other']


try:
    set_visible_devices([], 'GPU')
    visible_devices = get_visible_devices()
    for device in visible_devices:
        assert device.device_type != 'GPU'
except:
    print("Failed to disable GPUs, testing may be inaccurate")

# Load TFLite model and allocate tensors.
interpreter = Interpreter(model_path="models/XCeption-0.889.tflite")
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test model on prepared test input data.
matches = []
test_data = read_csv("./datasets/validation.csv").to_records(index=False)
for label, URL in test_data:
    try:
        img_data = Image.open(BytesIO(get(URL).content))
        if len(img_data.getdata()) > 0:
            result = predict(interpreter, img_data.resize(input_details[0]['shape'][1:3]))
            matches.append(1 if CLASS_NAMES.index(label) == argmax(result) else 0)
    except Exception as e:
        print(f"Test link {URL} invalid, skipping:\n{e}")

# Print testing result.
print(f"Test probability of model is: {round(sum(matches) / len(matches), 3)}")
