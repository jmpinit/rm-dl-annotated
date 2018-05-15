#!/usr/bin/env python

import sys
import os
import json
import xml.etree.ElementTree

def load_content_file(content_filepath):
    if not os.path.isfile(content_filepath):
        raise Exception('Content file "{}" does not exist'.format(content_filepath))

    with open(content_filepath, 'r') as content_file:
        return json.loads(content_file.read())

def transform_by_content_data(svg, content_data):
    root = svg.getroot()

    width = int(root.attrib['width'])
    height = int(root.attrib['height'])

    transform = content_data['transform']
    affine_matrix = [
        transform['m11'], transform['m12'], transform['m21'],
        transform['m22'], width * transform['m31'], height * transform['m32'],
    ]

    transform_group_element = xml.etree.ElementTree.Element('g')
    transform_group_element.attrib['transform'] = 'matrix({}, {}, {}, {}, {}, {})'.format(*affine_matrix)

    children_to_remove = []
    for child in root:
        transform_group_element.append(child)
        children_to_remove.append(child)
    
    for child in children_to_remove:
        root.remove(child)

    root.append(transform_group_element)

    return svg
        
def load_image(svg_filepath):
    if not os.path.isfile(svg_filepath):
        raise Exception('Image file "{}" does not exist'.format(svg_filepath))

    xml.etree.ElementTree.register_namespace('', 'http://www.w3.org/2000/svg')
    return xml.etree.ElementTree.parse(svg_filepath) 

def save_image(filename, svg):
    svg.write(filename)

def main():
    if not len(sys.argv) == 4:
        print('Usage: {} svg_image content_file'.format(sys.argv[0]))
        sys.exit(1)

    image = load_image(sys.argv[1])
    content_data = load_content_file(sys.argv[2])

    transformed_image = transform_by_content_data(image, content_data)

    save_image(sys.argv[3], transformed_image)

main()
