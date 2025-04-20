This repository is a branch of the [plotgardener](https://github.com/PhanstielLab/plotgardener) package, with only a few changes to make plotting a little bit more convenient for me.

Major changes include:
1. Adding a proper border around contact maps (plotHicSquare function)
2. Allowing flipping of the heatmap legend to the left of the map (annoHeatmapLegend)
3. Allow heatmap legend to span the full height of the contact map, instead of being shrunk to allow text on either side (annoHeatmapLegend)
5. Plotting specific, defined coordinates (plotGenomeLabel)
6. Option to plot ranges vertically instead of horizontally (plotRanges)
7. Matrices are automatically rasterized to allow easy handling when making figures (need to load rasterize package separately, haven't quite figured out how to make it load together)
