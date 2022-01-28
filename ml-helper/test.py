from tensorflow.python.framework.config import set_visible_devices, get_visible_devices
from tensorflow.lite.python.interpreter import Interpreter
from tensorflow.keras.backend import softmax, expand_dims
from argparse import ArgumentParser
from numpy import asarray, argmax
from pandas import read_csv
from requests import get
from io import BytesIO
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

# Load TFLite model and allocate tensors.
interpreter = Interpreter(model_path=args['network'])
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test model on prepared test input data.
matches = []
test_data = read_csv(args['source']).to_records(index=False)
for label, URL in test_data:
    try:
        img_data = Image.open(BytesIO(get(URL).content))
        if len(img_data.getdata()) > 0:
            result = predict(interpreter, img_data.resize(input_details[0]['shape'][1:3]))
            matches.append(1 if CLASS_NAMES.index(label) == argmax(result) else 0)
    except Exception as e:
        print(f"Test link {URL} invalid, skipping:\n{e}")

# Print testing result.
test_prob = sum(matches) / len(matches)
print(f"Test probability of model is: {round(test_prob, 3)} {'❌' if test_prob < DESIRED_RESULT else '✅'}")
exit(1 if test_prob < DESIRED_RESULT else 0)
