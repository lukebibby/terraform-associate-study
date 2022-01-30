

If the input variables in the child module do not have defaults, then a terraform run will fail.

```
Error: Missing required argument

  on servers.tf line 2, in module "webserver_cluster":
   2: module "webserver_cluster" {

The argument "instance_type" is required, but no definition was found.
```
