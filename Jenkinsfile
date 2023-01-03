pipeline {
    agent {
        docker {
            image 'maven:3.8-openjdk-17'
            args '-v /root/.m2:/root/.m2 -v /root/.ssh:/root/.ssh'
        }
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Unit Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Push Nexus') {
            steps {
                script {
                    POM_VERSION = sh (
                        script: 'mvn spring-boot:build-info | grep Building | awk \'{split(\$0,r," "); print r[4]}\'',
                        returnStdout: true
                    ).trim()

                    //update version for prod env, remove -SNAPSHOT
                    if ("${params.ENV_INFO}" == "prod") {
                        JAR_VERSION_WITHOUT_SNAPSHOT = sh (
                            script: "echo ${POM_VERSION} | awk '{split(\$0,r,\"-\"); print r[1]}' ",
                            returnStdout: true
                        ).trim()
                        sh "mvn versions:set -DnewVersion=${JAR_VERSION_WITHOUT_SNAPSHOT}"

                        JAR_FINAL_VERSION = sh (
                            script: "echo ${JAR_VERSION_WITHOUT_SNAPSHOT} ",
                            returnStdout: true
                        ).trim()
                    }else {
                        JAR_FINAL_VERSION = sh (
                            script: "echo ${POM_VERSION} ",
                            returnStdout: true
                        ).trim()
                    }
                }
                sh 'mvn clean install org.apache.maven.plugins:maven-deploy-plugin:2.8:deploy -DskipTests'
            }
        }
        stage('Package Image') {
            steps {
                script {
                    sh 'mvn clean package dockerfile:build -DskipTests'
                }
            }
        }
        stage('Push Image') {
            steps {
                script {
                    sh "sh deploy_docker.sh push ${JAR_FINAL_VERSION} ${params.ENV_INFO} "
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    //
                    if ("${params.Deploy_Port}" == "default") {
                        sh "sh deploy_docker.sh restart ${JAR_FINAL_VERSION} ${params.ENV_INFO} "
                    }else{
                        sh "sh deploy_docker.sh restart ${JAR_FINAL_VERSION} ${params.ENV_INFO} ${params.Deploy_Port}"
                    }
                }
            }
        }
        stage('Update version') {
            steps {
                script {
                    JAR_FINAL_VERSION = sh (
                        script: 'mvn spring-boot:build-info | grep Building | awk \'{split(\$0,r," "); print r[4]}\'',
                        returnStdout: true
                    ).trim()
                    MAJOR_VERSION = sh (
                        script: "echo ${JAR_FINAL_VERSION} | awk '{split(\$0,r,\"-\"); print r[1]}' | awk '{split(\$0,r,\".\"); print r[1] \".\" r[2]}\' ",
                        returnStdout: true
                    ).trim()
                    UPDATED_VERSION = sh (
                        script: "echo ${JAR_FINAL_VERSION} | awk '{split(\$0,r,\"-\"); print r[1]}' | awk '{split(\$0,r,\".\"); print r[3]}' | awk '{value=1+\$1} END{print value}' ",
                        returnStdout: true
                    ).trim()

                    sh "git branch -D ${params.GIT_Branch} || true"
                    sh "git checkout -b ${params.GIT_Branch} || true"
                    sh "mvn versions:set -DnewVersion=${MAJOR_VERSION}.${UPDATED_VERSION}-SNAPSHOT"
                    sh "git config user.email xxxxx@sample.com"
                    sh "git config user.name xxxxx"
                    sh "git commit -a -m 'Triggered Build: update pom version'"
                    sh "git push -u origin ${params.GIT_Branch}"
                }
            }
        }
    }
}
