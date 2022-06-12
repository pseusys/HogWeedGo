from tensorflow.python.framework.config import set_visible_devices, get_visible_devices
from sklearn.metrics import classification_report, accuracy_score
from tensorflow.lite.python.interpreter import Interpreter
from tensorflow.keras.backend import softmax, expand_dims
from argparse import ArgumentParser
from numpy import asarray, argmax
from pandas import read_csv
from requests import get
from io import BytesIO
from time import time
from PIL import Image
from sys import exit


def predict(inter, image):
    inter.set_tensor(input_details[0]['index'], expand_dims(asarray(image).astype('float32'), axis=0))
    inter.invoke()
    return softmax(inter.get_tensor(output_details[0]['index']))


DESIRED_RESULT = 0.9
CLASS_NAMES = ['hogweed', 'cetera', 'other']


try:
    set_visible_devices([], 'GPU')
    visible_devices = get_visible_devices()
    for device in visible_devices:
        assert device.device_type != 'GPU'
except:
    print("Failed to disable GPUs, testing may be inaccurate")

# Prepare argument parser
parser = ArgumentParser(description="Test created detector '.tflite' neural network")
parser.add_argument('-n', '--network', required=True, help="Network, saved in '.tflite' file")
parser.add_argument('-s', '--source', required=True, help="Dataset containing test dataset of labels and photo URLs")
args = vars(parser.parse_args())

# Load TFLite model and allocate tensors
interpreter = Interpreter(model_path=args['network'])
interpreter.allocate_tensors()

# Get input and output tensors
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Read input and get labels
test_data = read_csv(args['source']).to_records(index=False)
labels = [CLASS_NAMES.index(label) for label, _ in test_data]

# Test model on prepared test input data
results = []
time_total = 0
for label, URL in test_data:
    try:
        img_data = Image.open(BytesIO(get(URL).content))
        if len(img_data.getdata()) > 0:
            lap_time = time()
            result = predict(interpreter, img_data.resize(input_details[0]['shape'][1:3]))
            time_total += time() - lap_time
            results.append(argmax(result))
    except Exception as e:
        print(f"Test link {URL} invalid, exiting:\n{e}")
        exit(1)

# Print testing results
accuracy = accuracy_score(labels, results)
print(f"Model average execution time is: {round(time_total / len(results) * 1000)} ms")
print(classification_report(labels, results, target_names=CLASS_NAMES))
print(f"Test probability of model is: {round(accuracy, 3)} {'❌' if accuracy < DESIRED_RESULT else '✅'}")
exit(1 if accuracy < DESIRED_RESULT else 0)
