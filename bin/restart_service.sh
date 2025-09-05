#!/bin/bash
set -x

supervisorctl reread
supervisorctl update
supervisorctl restart fotohaeckertwo