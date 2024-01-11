
# import geopandas
# d = geopandas.read_file('netlogo/gis_data/test/poly.shp')
# print("DEBUG:", d) # DEBUG

def load_raster_layer(filename):
    import rasterio
    with rasterio.open(filename,'r') as fid:
        data = fid.read(1)
        return data
