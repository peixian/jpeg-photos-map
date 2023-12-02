#!/usr/bin/env python3

import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import os

# Expand the tilde to the user's home directory
csv_file = os.path.expanduser("~/code/writing/assets/shrines/locations.csv")
df = pd.read_csv(csv_file)

# Create figure and axis with transparent background
fig = plt.figure(figsize=(10, 6), facecolor='none')
ax = fig.add_subplot(111)
ax.patch.set_alpha(0)

# Create Basemap with a black background
map = Basemap(projection='robin', lat_0=0, lon_0=0, resolution='l')
map.drawcoastlines(linewidth=0.25, color="white")
map.drawcountries(linewidth=0.25, color="white")
map.drawmapboundary(fill_color='black')

# Plot each point from the DataFrame
for row in df.iterrows():
    d = row[1]
    x, y = map(d["Latitude"], d["Longitude"])
    map.scatter(x, y, marker="D", color="orange")

plt.savefig(os.path.expanduser("~/code/writing/assets/shrines/map.svg"),
            transparent=True, format='svg', bbox_inches='tight', pad_inches=0)
