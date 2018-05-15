#!/usr/bin/env python

import sys
import os
import json
import cv2
import numpy as np

def load_content_file(content_filepath):
    if not os.path.isfile(content_filepath):
        raise Exception('Content file "{}" does not exist'.format(content_filepath))

    with open(content_filepath, 'r') as content_file:
        return json.loads(content_file.read())

def transform_by_content_data(image, content_data):
    rows, cols, _ = image.shape
    transform = content_data['transform']
    affine_matrix = np.float32([
        [transform['m11'], transform['m21'], cols * transform['m31']],
        [transform['m12'], transform['m22'], rows * transform['m32']]
    ])

    return cv2.warpAffine(image, affine_matrix, (cols, rows), None, 0, cv2.BORDER_CONSTANT, (255, 255, 255))

def load_image(image_filepath):
    if not os.path.isfile(image_filepath):
        raise Exception('Image file "{}" does not exist'.format(image_filepath))

    return cv2.imread(image_filepath)

def save_image(filename, image):
    cv2.imwrite(filename, image)

def main():
    if not len(sys.argv) == 4:
        print('Usage: {} image content_file'.format(sys.argv[0]))
        sys.exit(1)

    image = load_image(sys.argv[1])
    content_data = load_content_file(sys.argv[2])

    transformed_image = transform_by_content_data(image, content_data)

    save_image(sys.argv[3], transformed_image)

main()
