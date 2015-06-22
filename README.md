# jvm-tools

## Compile or run without jvm installation

### TODO
- Create a user different than root for this stuff => Need to look at busybox how to
- I had some trouble trying with windows. The path are interpreted different than expecting. Need to find a way.

### You need [docker](https://github.com/tdeheurles/docs/tree/master/docker)

### The idea
You ask a container to do some work for you.

If you want him to build something for you, you give him the volume where he'll find the sources and where he can put the result. You also can ask him to leave a cache of the work in order to make the next work faster.


## what you need
- the path to the sources... should not be a problem
- For caches, the path in the container where the tools will cache everything (look at the Tools Path Section), and a path where you want to store that on your HOST
- you need to generate jvm-tools :
```
# Go to the Dockerfile path
➜ cd dockerFilePath

# build it (or run ./build.sh)
➜ docker build -t jvm-tools .

# Give an eye to your docker images, it should be in
➜ docker images
REPOSITORY      TAG       IMAGE ID       CREATED        VIRTUAL SIZE
jvm-tools       latest    9add15530a5c   2 hours ago    368.6 MB

```

### How to
```
# first go to your jar
➜ cd path/to/jarfileFolder

# and run
➜ docker run \
  --rm \
  -v "$(pwd):/workspace" \
  jvm-tools java -jar /workspace/jarfile
```
- Here we run the command `java -jar jarfile`
- `--rm` ask docker to remove the container after the work is done (remove the container, not the image)
- `-v "HostPath:ContainerPath" ` share a folder between host and container. In the example we share the current folder `pwd` with a folder `/workspace` in the container

### Example
We will create a scala/sbt project (via activator), build it, and run it. We will also add cache memory on our Host.

#### Create
First create the project :
```
➜ docker run \
    --rm  \
    -v ~/.ivy2:/root/.ivy2  \
    -v ~/.sbt:/root/.sbt \
    -v ~/.activator:/root/.activator \
    -v `pwd`:/workspace \
    -ti jvm-tools \
    /bin/bash -c "cd /workspace ; activator new"
```

And this is the output :
```
Fetching the latest list of templates...

Browse the list of templates: http://typesafe.com/activator/templates
Choose from these featured templates or enter a template name:
  1) minimal-akka-java-seed
  2) minimal-akka-scala-seed
  3) minimal-java
  4) minimal-scala
  5) play-java
  6) play-scala
(hit tab to see a list of all templates)
> 4
Enter a name for your application (just press enter for 'minimal-scala')
> foo
OK, application "foo" is being created using the "minimal-scala" template.
```

- Here, using `-v`, we have shared 3 path for cache `.ivy2`, `.activator`, `.sbt` and 1 to grab the created artifacts : `pwd`.
- Then `-ti jvm-tools` ask for running the container in interactive mode (because activator will ask some question)
- Finally with `/bin/bash -c`, we launch a bash command inside the container.

#### Build
```
➜ cd foo
➜ docker run \
    --rm
    -v ~/.ivy2:/root/.ivy2 \
    -v ~/.sbt:/root/.sbt \
    -v ~/.activator:/root/.activator \
    -v `pwd`:/workspace \
    jvm-tools \
    /bin/bash -c "cd /workspace ; activator run"
```

And you should see `Hello, world!`

You can also run activator in interactive mode by adding `-ti` before jvm-tools :
```
➜ docker run \
    --rm  \
    -v ~/.ivy2:/root/.ivy2 \
    -v ~/.sbt:/root/.sbt \
    -v ~/.activator:/root/.activator \
    -v `pwd`:/workspace \
    -ti jvm-tools
```

#### Simplify
Go to your .bashrc and add a function :
```
# jvm-tools
function jvm-tools {
➜ docker run 					\
    --rm  \
		-v ~/.ivy2:/root/.ivy2 			\
		-v ~/.sbt:/root/.sbt 			\
		-v ~/.activator:/root/.activator 	\
		-v `pwd`:/workspace 			\
		-ti jvm-tools /bin/bash -c "cd /workspace ; $1"
}
```

now you can :
```
➜ jvm-tools "activator new"
[...]

➜ jvm-tools "java -version"
java version "1.8.0_45"
Java(TM) SE Runtime Environment (build 1.8.0_45-b14)
Java HotSpot(TM) 64-Bit Server VM (build 25.45-b02, mixed mode)

➜ jvm-tools "javac -version"
javac 1.8.0_45

➜ jvm-tools "mvn -version"
Apache Maven 3.3.3 (7994120775791599e205a5524ec3e0dfe41d4a06; 2015-04-22T11:57:37+00:00)
Maven home: /maven
Java version: 1.8.0_45, vendor: Oracle Corporation
Java home: /usr/lib/jvm/java-8-oracle/jre
Default locale: en_US, platform encoding: ANSI_X3.4-1968
OS name: "linux", version: "3.19.0-21-generic", arch: "amd64", family: "unix"
```

You can add the content of .bashrc to your rc file

#### Path
Note that it doesn't matter where you store your shared folders on the Host, you just have to know where they are (or will appear) in the jvm-tools container.
