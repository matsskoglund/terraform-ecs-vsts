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
          "name": "AWS_ACCESS_KEY_ID",
          "value": "${env_AWS_ACCESS_KEY_ID}"
        },
         {
          "name": "AWS_SECRET_ACCESS_KEY",
          "value": "${env_AWS_SECRET_ACCESS_KEY}"
        },
   ],
   "mountPoints": [
      {
        "sourceVolume": "docker-dock",
        "containerPath": "/var/run/docker.sock"
      }
    ],
    
]
