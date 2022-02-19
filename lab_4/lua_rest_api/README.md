To run this Lua REST API:

 - Lua 5.1, Luarocks and Lapis should be installed:
     - `sudo apt install lua5.1`
     - `sudo apt-get install libssl-dev`
     - `sudo apt-get install luarocks`
     - `luarocks install --lua-version=5.1 lapis`
 - OpenResty should be installed:
     - https://www.installing.in/how-to-install-openresty-on-ubuntu-20-04/
 - PostgreSQL should be installed:   
     - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-20-04
     - start PostgreSQL server by running `sudo service postgresql start`
 - setup server environment: 
     - create a new directory for your project 
     - run `lapis new --lua` to create server files
     - copy `.lua` files from this repository to your project directory
     - run `lapis migrate` to migrate database schema and load sample data
     - run `lapis server` to start th server
 - go to `http://localhost:8080` to access the API
 - if any errors occur during this process install missing repositories mentioned in error messages using `luarocks install <package name>`
