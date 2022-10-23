#!/bin/sh
rsync --archive --compress --progress --partial --human-readable \
      --filter=":- ../.gitignore" --exclude=".git" $(pwd) \
      $UBERSPACE_USER@$UBERSPACE_SERVER:/home/$UBERSPACE_USER/
rsync --archive --compress --progress --partial --human-readable \
      $(pwd)/_uberspace/fotohaeckertwo.ini \
      $UBERSPACE_USER@$UBERSPACE_SERVER:/home/$UBERSPACE_USER/etc/services.d/fotohaeckertwo.ini

ssh -t uberspace 'cd fotohaecker && mix deps.get --only prod && MIX_ENV="prod" mix phx.digest.clean && MIX_ENV=prod mix assets.deploy'
ssh -t uberspace 'supervisorctl reread && supervisorctl update && supervisorctl restart fotohaeckertwo'