### jenkins 构造自动化部署镜像

![img](https://img-blog.csdnimg.cn/20190327131025159.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hpYW94aWFuZ3ppNTIw,size_16,color_FFFFFF,t_70)

### 构建命令

```
docker buildx build --platform linux/arm64 -f /opt/Dockerfile -t 2267024990/hello . --push
```

### 构建脚本

```shell
pipeline {

   agent {
      label 'aep-builder'
   }

   triggers {
      GenericTrigger(
         genericVariables: [
            [
               key: 'objectKind',
               value: '$.object_kind',
               expressionType: 'JSONPath'
            ],
            [
               key: 'gitHTTPURL',
               value: '$.repository.git_http_url',
               expressionType: 'JSONPath'
            ],
            [
               key: 'gitSSHURL',
               value: '$.repository.git_ssh_url',
               expressionType: 'JSONPath'
            ],
            [
               key: 'ref',
               value: '$.ref',
               expressionType: 'JSONPath'
            ],
            [
               key: 'after',
               value: '$.after',
               expressionType: 'JSONPath'
            ],
            [
               key: 'project_name',
               value: '$.repository.name',
               expressionType: 'JSONPath'
            ],
            [
               key: 'user_email',
               value: '$.commits[0].author.email',
               expressionType: 'JSONPath'
            ],
            [
               key: 'main_user_email',
               value: '$.user_email',
               expressionType: 'JSONPath'
            ]
         ],
         genericRequestVariables: [
            [
               key: 'image_name'
            ]
         ],

         causeString: 'Triggered on $ref',

         token: env.JOB_NAME,

         printContributedVariables: true,
         printPostContent: true,

         silentResponse: false,
      )
   }

   environment {
      // Load in environment
      after = "${after}"
      mainUserEmailValue = "${main_user_email}"
      userEmailValue = "${user_email}"
      projectNameValue = "${project_name}"
      imageNameValue = "${image_name}"
      // Image Full Path
      dockerRepositoryValue = sh (script: """
         if [[ "${objectKind}" == "tag_push" ]]; then
            tag_name=`echo ${ref} | awk -F'refs/tags/' '{print \$2}' | cut -c 1-4`
            if [[ "\${tag_name}" == "gie." ]]; then
               echo "ccr.ccs.tencentyun.com/gizwits_gie"
            else
               echo "ccr.ccs.tencentyun.com/gizwits_gems"
            fi
         else
            echo "ccr.ccs.tencentyun.com/gizwits_gems"
         fi
      """, returnStdout: true).trim()
      // Branche Value such as `tag/x.x.x` or `*/release/1.2.3`
      brancheValue = sh (script: """
         if [[ "${objectKind}" == "tag_push" ]]; then
            echo ${ref} | awk -F'refs/' '{print \$2}'
         elif [[ "${objectKind}" == "push" && ${ref} != "refs/heads/master" ]]; then
            echo ${ref} | sed 's/refs\\/heads/*/'
         else
            echo "null"
         fi
      """, returnStdout: true).trim()
      // Tag Value such as `1.2.3` or `release-1.2.3-abcdef`
      tagValue = sh (script: """
         if [[ "${objectKind}" == "tag_push" ]]; then
            echo ${ref} | awk -F'/' '{print \$3}'
         elif [[ "${objectKind}" == "push" && ${ref} != "refs/heads/master" ]]; then
            prefix=`echo ${ref} | awk -F'refs/heads/' '{print \$2}' | sed 's/\\//-/'`
            suffix=`echo ${after} | cut -c 1-6`
            echo \${prefix}-\${suffix}
         else
            echo "null"
         fi
      """, returnStdout: true).trim()
   }

   stages {
      stage('Info') {
         steps {
            echo "dockerRepositoryValue ${dockerRepositoryValue}"
            echo "imageNameValue ${imageNameValue}"
            echo "brancheValue ${brancheValue}"
            echo "tagValue ${tagValue}"
            echo "userEmail ${userEmailValue}"
         }
      }

      stage('Pull') {
         when {
            allOf {
               expression {
                  return brancheValue != "null"
               }
               expression {
                  return imageNameValue != "null"
               }
               expression {
                  return tagValue != "null"
               }
               expression {
                  return after != "0000000000000000000000000000000000000000"
               }
            }
         }
         steps {
            checkout([
                $class: 'GitSCM',
                branches: [[name: "${brancheValue}"]],
                doGenerateSubmoduleConfigurations: true,
                extensions: [[
                    $class: 'CleanBeforeCheckout'
                ],[
                    $class: 'CleanCheckout'
                ],[
                    $class: 'SubmoduleOption', recursiveSubmodules: true, trackingSubmodules: true, parentCredentials: true, timeout: 120
                ]],
                submoduleCfg: [],
                userRemoteConfigs: [[
                    credentialsId: 'opsci',
                    url: "${gitHTTPURL}"
                ]]
            ])
         }
      }

      stage('Test') {
         when {
            allOf {
               expression {
                  return brancheValue != "null"
               }
               expression {
                  return imageNameValue != "null"
               }
               expression {
                  return tagValue != "null"
               }
               expression {
                  return after != "0000000000000000000000000000000000000000"
               }
            }
         }
         steps {
            echo "Test"
         }
      }

      stage('Build And Push') {
         when {
            allOf {
               expression {
                  return brancheValue != "null"
               }
               expression {
                  return imageNameValue != "null"
               }
               expression {
                  return tagValue != "null"
               }
               expression {
                  return after != "0000000000000000000000000000000000000000"
               }
            }
         }
         steps {
            sh """
            if [ -f "./build/Dockerfile" ]; then
                docker buildx build . -t ${dockerRepositoryValue}/${imageNameValue}:${tagValue} -f ./build/Dockerfile --platform linux/amd64 --build-arg VERSION=${tagValue} --push
            else
                docker buildx build . -t ${dockerRepositoryValue}/${imageNameValue}:${tagValue} -f ./Dockerfile --platform linux/amd64 --build-arg VERSION=${tagValue} --push
            fi
            """
         }
      }
   }


   post {
      always {
         echo "Send notifications for result: ${currentBuild.result}, and display name: ${currentBuild.fullDisplayName}"
      }

      success {
         echo "This project is success"
         sh "curl -LO https://jzhuang-1254961755.cos.ap-guangzhou.myqcloud.com/email.html"
         script {
            def emailNotify = readFile file: './email.html', encoding: 'UTF-8'
            if ("${env.brancheValue}" != "null" && "${env.after}" != "0000000000000000000000000000000000000000") {
               if ("${env.userEmailValue}" != "null") {
                  emailext to: "${env.userEmailValue}", subject: "${env.projectNameValue}"+' - Build $BUILD_STATUS - '+"DockerImage: ${dockerRepositoryValue}/${imageNameValue}:${tagValue}", body: "${emailNotify}"
               }
               if ("${env.mainUserEmailValue}" != "null") {
                  emailext to: "${env.mainUserEmailValue}", subject: "${env.projectNameValue}"+' - Build $BUILD_STATUS - '+"DockerImage: ${dockerRepositoryValue}/${imageNameValue}:${tagValue}", body: "${emailNotify}"
               }
            }
         }
      }

      failure {
         echo "This project is fail"
         sh "curl -LO https://jzhuang-1254961755.cos.ap-guangzhou.myqcloud.com/email.html"
         script {
            def emailNotify = readFile file: './email.html', encoding: 'UTF-8'
            if ("${env.brancheValue}" != "null" && "${env.after}" != "0000000000000000000000000000000000000000") {
               if ("${env.userEmailValue}" != "null") {
                  emailext to: "${env.userEmailValue}", subject: "${env.projectNameValue}"+' - Build $BUILD_STATUS - '+"DockerImage: ${dockerRepositoryValue}/${imageNameValue}:${tagValue}", body: "${emailNotify}"
               }
               if ("${env.mainUserEmailValue}" != "null") {
                  emailext to: "${env.mainUserEmailValue}", subject: "${env.projectNameValue}"+' - Build $BUILD_STATUS - '+"DockerImage: ${dockerRepositoryValue}/${imageNameValue}:${tagValue}", body: "${emailNotify}"
               }
            }
         }
      }
   }

}
```

### 开发计划

1. 使用jenkins、pipeline，运行镜像构建脚本。构造镜像到dockerHub。
2. 使用webHook监听代码库pull（tag），实时构建镜像

开发注意事项

1. 打包机需要得到登陆授权dockerHub、同步密钥在github
2. 原则上，jenkins不进行打包操作，应该协同master和slave协同
3. 



Pipeline定义：

​	agent/options

1. ​	指定node节点、workspace
2. 指定运行选项

​	stages

1. 运行阶段

post

1. 构建后操作

   success、failure、aborted(surrentBuild内置变量)

运行镜像

```
docker run -itd --name myJenkins -p 8081:8087 -p 50000:50000 -v /root/dockerTest/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins:v1
```

### 配置信息

1. dockerHUb：dockerhub:22670.abc
2. github Personal access tokens：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
3. jenkins API Token：testToken：111d48b293b41eee009d394ee579476a0d
4.  pipelineTest03：1113fca13f1b9a94c4940ac02703d1d5fc

### 镜像构建命令

```
docker buildx build --platform linux/arm64 -f Dockerfile -t 2267024990/hello . --push
```

```
JENKINS_URL`/job/pipeline2/build?token=`TOKEN_NAME
http://192.168.56.133:8081/generic-webhook-trigger/invoke?token=123456
```

```
ssh-keygen -t rsa -C "yc_13456@163.com"
ssh -T git@github.com
```



```mermaid
graph LR
C[WebHook触发] --> A[jenkins Pipeline执行脚本] --> B[groovy脚本构建镜像] -->D[推送到dockerHub]

C --> F[注释:没有外网IP/域名可以触发WebHook<br/>1.需要开放两个端口用于WebHook:8080,50000等]
A -->g[注释:使用Generic Webhook Trigger插件进行触发执行<br/>存在数据交互:email等]
B -->h[注释:需要指定打包机环境<br/>是否采取master/slave<br/>1.指定VIM3打包?<br/>2.选择合适服务器进行打包]
D -->i["注释：docker镜像HUb存放地址"]
```

### 端口介绍

1. 8080端口是web访问的端口
2. 50000端口是基于的JNLP的Jenkins代理(salve)通过tcp与jenkins(master)进行通信的端口

docker buildx build --platform linux/arm64 -t ccr.ccs.tencentyun.com/gizwits_gems/qcr4t-algorithm-arm64:test -f build/Dockerfile --build-arg VERSION="test" .

```
本地测试镜像
docker buildx build -t ccr.ccs.tencentyun.com/gizwits_gems/qcr4t-algorithm-arm64:test1 --platform=linux/arm64 -o type=docker,dest=- . >myimage.tar -f build/Dockerfile
```

