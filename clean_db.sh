#!/bin/bash

source db_info.sh

mix ecto.drop && mix ecto.create && mix ecto.migrate