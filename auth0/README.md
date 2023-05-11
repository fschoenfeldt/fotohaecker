# auth0 deploy

## setup

- install [auth0 deploy](https://github.com/auth0/auth0-deploy-cli)
- copy `config.json.example` to `config.json` and fill in the values

## download from auth0

```sh
a0deploy export --format directory --config_file config.json --output_folder=./ --env=false
```

## upload to auth0

```sh
a0deploy import --config_file config.json --input_file=./ --env=false
```
