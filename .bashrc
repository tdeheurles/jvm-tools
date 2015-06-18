
# jvm-tools
function jvm-tools {
	docker run 					\
		--rm					\
		-v ~/.ivy2:/root/.ivy2 			\
		-v ~/.sbt:/root/.sbt 			\
		-v ~/.activator:/root/.activator 	\
		-v `pwd`:/workspace 			\
		-ti jvm-tools /bin/bash -c "cd /workspace ; $1"
}
