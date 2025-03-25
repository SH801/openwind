# CKAN 2 Datafiles Batch Converter

## Outline

The purpose of this script is to automate the process of downloading a CKAN data catalogue and creating output layers from the downloaded data. The code is written in Python, ideally v3.9 (for compatibility with `GDAL` which is required for `osm-export-tool`)

## How it works

- Downloads CKAN package information using Python library `ckanapi`
- Searches downloaded package information for ArcGIS, WFS, GeoJSON, KML/KMZ and 'osm-export-tool YML' links and downloads them
- When downloaded file is 'osm-export-tool YML' file, this is used to generate OSM data from a bulk OSM file; note: this process is very time-consuming
- All downloaded datasets are converted to GeoJSON
- If CKAN record for dataset has 'buffer' value, this value is used to generate a buffered file

## Python 3.9

To work with `osm-export-tool`, you should use Python 3.9 (due to problems that were experienced on MacOS Silicon by Stefan with Python > 3.9)

## Installation

Install `virtualenv`:
```
pip3 install virtualenv
```

Install `python3.9`. 

To install Python 3.9 on Mac with Homebrew package manager:
```
brew install python@3.9
```

To install Python 3.9 on Ubuntu:
```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.9
```

Find location of Python 3.9:
```
which python3.9
```

Create virtual environment for Python3.9:
```
virtualenv -p [directory-from-previous-step] venv
```

Activate virtual environment:
```
source venv/bin/activate
```

Load script and necessary Python libraries
```
git clone https://github.com/Olwg-Ltd/ckan-2-olsights-batch
cd ckan-2-olsights-batch
pip3 install -r requirements.txt
```

Modify the `.env` file to reflect the location of different databases and login details:
```
cp .env.sample .env
nano .env
```

## Description of naming conventions

All imported datasets and derived materialized views and functions will have the `dcat__` prefix to indicate they have originated from a data catalogue. In addition, the `mv__` or `fn__` prefix indicates the database object differs in a non-trivial way from the source data. For example, different datasets may have non-standard ways of referring to a feature's `id` and `name` field within the dataset. This makes it difficult to aggregate different datasets and so harmonization of field names is necessary. The `ckan2olsights.py` script therefore attempts to *guess* each dataset's `id` and `name` field and creates a `dcat__mv__[dataset_descriptor]` materialized view which may differ substantially from the original `dcat__[dataset_descriptor]`. 

In summary:

- If a `dcat__...` database object name lacks `mv__` or `fn__`, it will be identical to the original source data used to generate it.
- The field names of a `dcat__mv__...` or `dcat__fn__...` database object may differ substantially from the original source data used to generate it. 

## Open Street Map (OSM) pipeline

The script uses `yml` config files in combination with `osm-export-tool` [https://github.com/hotosm/osm-export-tool-python] to download Open Street Map (OSM) data. Prior to running the script, you should ensure you have the `osm-export-tool` Python library installed. It is recommended you do this using a Python virtual environment.

### Setting up environment to download GPKG file for specified OSM layer
- Install Python 3.9
- Set up Python virtual environment:

```
which python3.9
virtualenv -p [directory-from-above] venv 
source venv/bin/activate
pip install osm-export-tool
```

To test everything is working correctly, download a osm-export-tool `yml` config file from https://ckan.wewantwind.org and do the following:
```
wget https://download.geofabrik.de/europe/britain-and-ireland-latest.osm.pbf
osm-export-tool britain-and-ireland-latest.osm.pbf osm_download -m [downloaded-yml-name].yml
```

Load the `osm-download.gpkg` in QGIS to check the results are correct.

## To run CKAN 2 Olsights batch import script

```
python3 ckan2olsights.py
```

Note: there may be lengthy delays while the script runs, particularly as it downloads the latest OSM data and runs `osm-export-tool` on this data.

## Details

The script uses the ```group``` structure within CKAN to group layers into ```sections```, eg. ```Landscape and visual impact```, and also group layers that span multiple areas, eg. ```National Parks - England```, ```National Parks - Scotland```... will have their own materialized view but will also be collected under a single ```dcat__mv__national_parks``` materialized view.

## Naming conventions within database

- All table and view names will be lowercase and spaces will be replaced by underscores.
- All tables and view names will be prefaced with ```dcat__``` to reflect their data catalogue (DCAT) origin. This is designed to separate them from legacy/ad-hoc datasets already in the database. 
- All materialized views will have ```__mv__``` between the initial ```dcat``` and the rest of the dataset title, eg. ```dcat__mv__national_parks__scotland```
- All functions will have ```__fn__``` between the initial ```dcat``` and the rest of the dataset title, eg. ```dcat__fn__heritage_impacts```
- Structural separation from ```section``` -> ```subsection``` -> ```location``` will be separated by two underscores, eg. ```dcat__national_parks__scotland``` and ```dcat__mv__national_parks__scotland```



