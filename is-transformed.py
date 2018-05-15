#!/usr/bin/env python

import sys
import json

unit_transform = {
  'm11': 1,
  'm12': 0,
  'm13': 0,
  'm21': 0,
  'm22': 1,
  'm23': 0,
  'm31': 0,
  'm32': 0,
  'm33': 1,
}

def main():
  if not len(sys.argv) == 2:
    print('Usage: {} contentfile'.format(sys.argv[0]))
    sys.exit(1)

  content_filepath = sys.argv[1]

  with open(content_filepath, 'r') as content_file:
    content_data = json.loads(content_file.read())
    transform = content_data['transform']

    for cellname in unit_transform:
      if not unit_transform[cellname] == transform[cellname]:
        print('Yes')
        sys.exit(0)

    print('No')
    sys.exit(0)

  # Something went wrong, don't know what
  sys.exit(1)

main()
