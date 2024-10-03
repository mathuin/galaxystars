# galaxystars

This is a practice project to help me learn more about Swift and Vapor, specifically Fluent.  It's a simple CRUD app for galaxies, stars, asteroids, and planets.

* Galaxies can be created empty or with stars
* Stars can be created with or without asteroids and planets, but must be added to a galaxy on creation
* Asteroids and planets must be added to a star on creation
* Deleting a star deletes its associated asteroids and planets, and galaxies behave similarly

There is no support for moving a star between galaxies, or moving minor bodies between stars.

## Quick start!

Set up a local PostgreSQL instance and configure environment variables as seen in `configure.swift`.

Create the tables and such with this:

```
% swift run App migrate
```

Open Package.swift in Xcode and hit the triangle to start the app, or from the terminal:

```
% swift run
```

The app should start up on localhost on port 8080.

Now add a galaxy, complete with a star that has an asteroid and a planet:
```
% curl --header "Content-Type: application/json" --request POST --data '{ "stars": [ { "planets": [ { "name": "Earth" } ], "asteroids": [ { "name": "Ceres" } ], "name": "Sun" } ], "name": "Milky Way" }' http://localhost:8080/galaxies
{"name":"Milky Way","stars":[{"planets":[{"name":"Earth","id":"F521961A-4D81-4BC7-8C9E-D59AC7E7D7D1"}],"id":"E4C461BC-E709-436C-AC57-2E2F7880728B","asteroids":[{"id":"FFBD1BF7-5B25-4026-BE7B-202E491D5522","name":"Ceres"}],"name":"Sun"}],"id":"FCC0E44C-9D30-454C-B0C3-82E4528A44A6"}
```
The output shows the ID values for each of the objects.  These ID values can be used to examine individual objects, like this:

```
% curl -s http://localhost:8080/stars/E4C461BC-E709-436C-AC57-2E2F7880728B
{"name":"Sun","asteroids":[{"name":"Ceres","id":"FFBD1BF7-5B25-4026-BE7B-202E491D5522"}],"planets":[{"name":"Earth","id":"F521961A-4D81-4BC7-8C9E-D59AC7E7D7D1"}],"id":"E4C461BC-E709-436C-AC57-2E2F7880728B"}
```

To list all objects of a particular type, try something like this:

```
% curl -s http://localhost:8080/planets/
[{"name":"Earth","id":"F521961A-4D81-4BC7-8C9E-D59AC7E7D7D1"}]
```

To delete objects, try something like this:
```
% curl -X DELETE http://127.0.0.1:8080/galaxies/FCC0E44C-9D30-454C-B0C3-82E4528A44A6
% curl http://127.0.0.1:8080/galaxies/
[]
```

Have fun!