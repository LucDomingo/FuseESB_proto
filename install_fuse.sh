# Login
oc login --token={TOKEN} --server=https://api.ca-central-1.starter.openshift-online.com:6443
# Installation des Images Streams (spécificité de OpenShift). De ce que j ai compris c est un objet qui fait le lien entre l image sur le repo et celle utilisée par les
# pods. Ainsi dès qu'une nouvelle image est push il peut y avoir une mise à jour automatique selon des politiques que nous pouvons définir (Rolling Update,...)
BASEURL=https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001
oc create -f https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001/fis-image-streams.json
for template in eap-camel-amq-template.json \
 eap-camel-cdi-template.json \
 eap-camel-cxf-jaxrs-template.json \
 eap-camel-cxf-jaxws-template.json \
 eap-camel-jpa-template.json \
 karaf-camel-amq-template.json \
 karaf-camel-log-template.json \
 karaf-camel-rest-sql-template.json \
 karaf-cxf-rest-template.json \
 spring-boot-camel-amq-template.json \
 spring-boot-camel-config-template.json \
 spring-boot-camel-drools-template.json \
 spring-boot-camel-infinispan-template.json \
 spring-boot-camel-rest-sql-template.json \
 spring-boot-camel-teiid-template.json \
 spring-boot-camel-template.json \
 spring-boot-camel-xa-template.json \
 spring-boot-camel-xml-template.json \
 spring-boot-cxf-jaxrs-template.json \
 spring-boot-cxf-jaxws-template.json ;
 do
 oc create -f \
 https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001/quickstarts/${template}
 done
oc create -f https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001/fis-console-cluster-template.json
oc create -f https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001/fis-console-namespace-template.json
oc create -f https://raw.githubusercontent.com/jboss-fuse/application-templates/application-templates-2.1.fuse-720018-redhat-00001/fuse-apicurito.yml

# ---------- Solution 1 --------------- (templates)
# Une fois arrivé ici on peut instancier réellement Fuse car le lien est fait avec toutes les images nécessaire (camel,...)
# Des templates sont disponible. Se rendre sur la page Developer/+Add, cliquer sur FromCatalog puis trouver Red Hat Fuse 7.2 Camel XML DSL with Spring Boot.
# La config des routes Camel, ce fera dans Spring Boot via Blueprint dans ce cas là.
# ----------- Solution 2 --------------
# Installer Maven / Télécharger https://maven.apache.org/download.cgi (jdk >= 1.7)
# sudo apt-get install openjdk-8-jre
# export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/
# export PATH=$PATH:$JAVA_HOME/bin
# Rajouter les repo/plug-in https://repo1.maven.org/maven2|https://maven.repository.redhat.com/ga|https://maven.reposit
# Voir settings.xml
# docker login -u USER -p MDP registry.redhat.io
# mvn -Pmyprofile org.apache.maven.plugins:maven-archetype-plugin:2.4:generate \
#  -DarchetypeCatalog=https://maven.repository.redhat.com/ga/io/fabric8/archetypes/archetypes-catalog/2.2.0.fuse-720018-redhat-00001/archetypes-catalog-2.2.0.fuse-720018-redhat-00001-archetype-catalog.xml \
#  -DarchetypeGroupId=org.jboss.fuse.fis.archetypes \
#  -DarchetypeArtifactId=spring-boot-camel-xml-archetype \
#  -DarchetypeVersion=2.2.0.fuse-720018-redhat-00001
# Define value for property 'groupId': : org.example.fis
# Define value for property 'artifactId': : fuse72-spring-boot
# cd fuse72-spring-boot
# mvn fabric8:deploy -Popenshift
# Cette commande fais bcp de choses (compilation, construction des conteneurs, déploiement dans openshift). Justement c'est sur cette dernière étape que j'obtenais des erreurs. Après plusieurs heures passées,
# il s'avère que la version de Fabric8 (en charge du déploiement) n'est pas compatible avec la version d'openshift online (v4). Il y a moyen de contourner ce problème en indiquant manuellement à openshift ou aller
# chercher les images docker. Donc il suffit de faire un push de l'image construire par maven sur DockerHub.
# Attention dans les Dockerfile sous fuse75-spring-boot-camel-amq/target/docker/fuse75-spring-boot-camel-amq/latest/build les images de bases de type fuse7-java-openshift:1.5
# sont en général introuvable directement par Docker (pour avoir une config permanente peut être faut-il modifier le repo par défaut)
# docker login -u USER -p MDP registry.redhat.io && docker pull  registry.redhat.io/fuse7/fuse-java-openshift:1.5 puis construire à la main le conteneur
