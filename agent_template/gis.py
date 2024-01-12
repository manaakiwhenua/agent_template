
def load_raster(filename):
    """Load a single layer raster file into a grid"""
    import rasterio
    with rasterio.open(filename,'r') as fid:
        data = fid.read(1)
        return data

def load_vector(filename):
    """Load a single vector land use file"""
    import geopandas
    data = geopandas.read_file(filename)
    return data
