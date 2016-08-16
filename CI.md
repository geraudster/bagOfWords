Jenkins conf:

* Install Pipeline plugin
* CloudBees Docker Pipeline plugin
* Install docker
* Build Pipeline plugin

Run it:

    docker run -p 8080:8080 -p 50000:50000 -v /home/geraud/jenkins:/var/jenkins_home jenkins
