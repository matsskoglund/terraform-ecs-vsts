[
  {
    "name": "vsts",
    "image": "matsskoglund/vsts-docker-agent:latest",
    "cpu": 512,
    "memory": 1024,
    "essential": true,
  },
   "environment": [
        {
          "name": "VSTS_ACCOUNT",
          "value": "${env_VSTS_ACCOUNT}"
        },
        {
          "name": "VSTS_TOKEN",
          "value": "${env_VSTS_TOKEN}"
        },
        {
          "name": "AWS_ACCESS_KEY",
          "value": "${env_AWS_ACCESS_KEY}"
        },
         {
          "name": "AWS_SECRET_KEY",
          "value": "${env_AWS_SECRET_KEY}"
        },
   ],
   "mountPoints": [
      {
        "sourceVolume": "docker-dock",
        "containerPath": "/var/run/docker.sock"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
       "options": {
        "awslogs-group": "${log-group}",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "${log-stream}"
        }
      }
    
]
