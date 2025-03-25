# Installation

## Software Required

- PostGIS: For storing and processing GIS data
- Python3.9: For compatibility with osm-export-tool
- GDAL: For transferring data in and out of PostGIS
- QGIS: For generating QGIS files
- tilemaker: For generating mbtiles version of OpenStreetMap for use as background map within MapLibre-gl
- tippecanoe: For generating optimized mbtiles versions of data layers for MapLibre-gl
- Docker [not mandatory]: For previewing final data in tileserver-gl

## Ubuntu

Install main software and libraries required to compile tilemaker and tippecanoe:

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install  gnupg software-properties-common cmake make g++ dpkg ca-certificates \
                  libbz2-dev libpq-dev libboost-all-dev libgeos-dev libtiff-dev libspatialite-dev \
                  liblua5.4-dev rapidjson-dev libshp-dev libgdal-dev shapelib \
                  spatialite-bin sqlite3 lua5.4 gdal-bin \
                  zip unzip curl nano wget pip git nodejs npm proj-bin \
                  postgresql-postgis qgis qgis-plugin-grass \
                  python3.9 python3.9-dev python3.9-venv python3-gdal -y
```

Install tilemaker and tippecanoe for building mbtiles vector tiles:

```
git clone https://github.com/systemed/tilemaker.git
cd tilemaker
make
sudo make install
cd ..

git clone https://github.com/mapbox/tippecanoe.git
cd tippecanoe
make -j
sudo make install
cd ..
```

Check they have both installed correctly by typing:
```
tilemaker --help
tippecanoe --help
```

Install Node Version Manager (`nvm`) and `togeojson`:
```
curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash
source ~/.bashrc

nvm install v10.19.0
nvm use v10.19.0
npm install -g @mapbox/togeojson
```
Check `togeosjon` has installed correctly by typing:
```
togeojson
```
Clone OpenWind project repo, create Python virtual environment and install required Python libraries:
```
git clone git@github.com:SH801/openwind.git
cd openwind
cp .env-template .env

/usr/bin/python3.9 -m venv venv
source venv/bin/activate

pip3 install gdal==`gdal-config --version`
pip3 install -r requirements.txt
pip3 install git+https://github.com/hotosm/osm-export-tool-python --no-deps
```

Set up PostGIS:
```
sudo -u postgres createuser -P openwind
sudo -u postgres createdb -O openwind openwind
sudo -u postgres psql -d openwind -c 'CREATE EXTENSION postgis;'
sudo -u postgres psql -d openwind -c 'GRANT ALL PRIVILEGES ON DATABASE openwind TO openwind;'
```
When prompted use password `password` -  or enter a different password and edit the `POSTGRES_PASSWORD` field in `.env` file accordingly.

Install folder of openmaptiles fonts:
```
git clone https://github.com/openmaptiles/fonts
cd fonts
npm install
node ./generate.js
```
If you experience problems compiling openmaptiles fonts, generate the same fonts using a temporary Docker instance:
```
docker buildx build --platform linux/amd64 -t openwind-fonts -f openwind-fonts.dockerfile .
docker run -v $(PWD)/build-cli/:/build-docker/ openwind-fonts
```
Note: this Docker instance uses platform emulation (`linux/amd64`) to avoid compilation issues affecting Silicon architectures.

Finally to view final results of the data pipeline through a Docker version of tileserver-gl, install Docker:

```
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```
Alternatively, install `tileserver-gl` without Docker using [these instructions](https://github.com/maptiler/tileserver-gl)