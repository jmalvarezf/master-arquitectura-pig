#!/bin/bash

# Open Jupyter
docker exec -it namenodesl /opt/anaconda/bin/jupyter notebook --port 8889 --notebook-dir='/media/notebooks' --ip='*' --no-browser --allow-root
