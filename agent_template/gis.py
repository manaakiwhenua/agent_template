
def load_raster(filename):
    """Load a single layer raster file into a grid"""
    import rasterio
    with rasterio.open(filename,'r') as fid:
        data = fid.read(1)
        return data

def load_vector(
        filename,               # filename to load polygons from
        buffer=0,               # also create polygons with this buffer distance
):
    """Load a single vector land use file"""
    import geopandas
    data = geopandas.read_file(filename)
    geometry = data['geometry']
    geometry_with_buffer = geometry.buffer(buffer)
    return data,geometry,geometry_with_buffer
