#!/bin/sh
rsync --archive --compress --progress --partial --human-readable \
      --filter=":- ../.gitignore" --exclude=".git" $(pwd) \
      $UBERSPACE_USER@$UBERSPACE_SERVER:/home/$UBERSPACE_USER/
rsync --archive --compress --progress --partial --human-readable \
      $(pwd)/_uberspace/fotohaeckertwo.ini \
      $UBERSPACE_USER@$UBERSPACE_SERVER:/home/$UBERSPACE_USER/etc/services.d/fotohaeckertwo.ini

# TODO: find a better way to do this
# somehow, pnpm doesn't get recognized when using with mix
ssh -t uberspace 'cd fotohaecker && EXQLITE_USE_SYSTEM=1 EXQLITE_SYSTEM_CFLAGS="-I/usr/include" EXQLITE_SYSTEM_LDFLAGS="-L/lib64/sqlite -lsqlite3" mix deps.get --only prod && EXQLITE_USE_SYSTEM=1 EXQLITE_SYSTEM_CFLAGS="-I/usr/include" EXQLITE_SYSTEM_LDFLAGS="-L/lib64/sqlite -lsqlite3" MIX_ENV=prod mix compile && MIX_ENV="prod" mix phx.digest.clean && npm --prefix assets install && MIX_ENV=prod mix assets.deploy'
ssh -t uberspace 'supervisorctl reread && supervisorctl update && supervisorctl restart fotohaeckertwo'
