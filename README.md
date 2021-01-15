# Fotohaecker

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:1337`](http://localhost:1337) from your browser.

## Notes

Commands used:

- `photos`: `mix phx.gen.live Content Photo photos title:string description:string path:string tags:{:array, string} uploaded:utc_datetime`
- `users`: `mix phx.gen.live Accounts User users name:string password:string email:string profile_picture:string`
