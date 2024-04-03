# Cloud Engineering Team Project

## Running Terraform to create the infrastructure

First get credentials for AWSAdministratorAccess (for example, via [Environment variables to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html?icmpid=docs_sso_user_portal)) then apply the terraform code in the `terraform` directory with `terraform apply` to create the VPC networking and EKS containerisation on AWS.

Next apply the terraform code in the `database` directory with `terraform apply` to create the AWS RDS database instance, take note of the database url.

## Connect Database

Insert the url for the database in the `dbHost` value in the file `helm/backend/values.yaml`.

## Installing the Helm Charts

First, from the `helm` directory install the backend server. Next update the frontend `values.yaml` file with the DNS of the backend service. Then install the frontend.

### Install the Backend Server

To install the chart with the release name `backend` from within the `helm` directory use:

```bash
helm install backend ./backend
```

> Note: the chart can be installed with any release name just replace `backend` with your preferred name.

Next take a note of the `EXTERNAL-IP` of the `be-service` in order to configure the frontend:

```bash
kubectl get service
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP                 PORT(S)        AGE
be-service   LoadBalancer   172.20.30.224   ad422xxx.amazonaws.com      80:30125/TCP   70m
```

> Note: in this example the `EXTERNAL-IP` `ad422aa3fd4e643b4af04018dd421b7e-6446255.eu-west-2.elb.amazonaws.com` has been abbreviated to `ad422xxx.amazonaws.com`

### Install the Frontend Server

Before installing the frontend update the `baseApi` value in the `values.yaml` with the DNS from the previous step. For example:

```yaml
baseApi: ad422aa3fd4e643b4af04018dd421b7e-6446255.eu-west-2.elb.amazonaws.com
```

Next install the chart with the release name `frontend` from the within helm directory:

```bash
helm install frontend ./frontend
```

> Note: again the chart can be installed with any release name, just replace `frontend`.

Next take a note of the `EXTERNAL-IP` of the `fe-service` and use this in the Web Browser to access the frontend.

```bash
kubectl get service
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP              PORT(S)        AGE
fe-service   LoadBalancer   172.20.214.61   ade14xxx.amazonaws.com   80:30231/TCP   27m
```

> Note: in this example `EXTERNAL-IP` `ade14ac02cd1149119f3683676b4cc79-1691019730.eu-west-2.elb.amazonaws.com` is abbreviated.

Then use `http://ade14ac02cd1149119f3683676b4cc79-1691019730.eu-west-2.elb.amazonaws.com` to access the frontend app.

## Installing Jenkins

First create a namespace for Jenkins, for example `devops-tools`

```bash
kubectl create namespace devops-tools
```

> It is recommended to categorise DevOps tools as a separate namespace from other applications.

Next create a service account with Kubernetes admin permissions by applying the `serviceAccount.yaml` file.

```bash
kubectl apply -f serviceAccount.yaml
```

> The `serviceAccount.yaml` creates a 'jenkins-admin' clusterRole, 'jenkins-admin' ServiceAccount and binds the 'clusterRole' to the service account. The 'jenkins-admin' cluster role has all the permissions to manage the cluster components.

Now create a local persistent volume for persistent Jenkins data on Pod restarts by applying the `volume.yaml` file.

```bash
kubectl create -f volume.yaml
```

> **Important Note**: Replace the node value in this file with any one of the cluster worker nodes hostname. You can get the worker node hostname using `kubectl get nodes`

Create a deployment YAML by applying the `deployment.yaml` file.

```bash
kubectl apply -f deployment.yaml
```

> The deployment file uses local storage class persistent volume for Jenkins data. For production use cases, a cloud-specific storage class persistent volume for your Jenkins data is recommended.

Finally, create the Jenkins service by applying the `service.yaml` file.

```bash
kubectl apply -f service.yaml
```

Now in the list of your services, there will be a jenkins-service of type LoadBalancer with a public dns to access Jenkins on port 8080. For example: `http://af333cb778e604b3f9730ea4ce1e7814-350983585.eu-west-2.elb.amazonaws.com:8080` will provide access to the Jenkins dashboard.

> Note: To find the jenkins-service run `kubectl get services -n devops-tools`

### Initial Admin password

Jenkins will ask for the initial Admin password when you access the dashboard for the first time.

You can get this from the pod logs either from the Kubernetes dashboard or CLI. You can get the pod details using the following CLI command.

```bash
kubectl get pods -n devops-tools
```

With the pod name, you can get the logs as shown below. Replace the pod name with your pod name.

```bash
kubectl logs jenkins-56b6774bb6-vflqs -n devops-tools
```

The password can be found at the end of the log.

Alternatively, you can run the exec command to get the password directly from the location as shown below.

```bash
kubectl exec -it jenkins-56b6774bb6-vflqs cat /var/jenkins_home/secrets/initialAdminPassword -n devops-tools
```

> Note: You will have to change `jenkins-56b6774bb6-vflqs` to match the name of your pod.

Once you enter the password, proceed to install the suggested plugin and create an admin user.

You should now successfully have access to the Jenkins dashboard!

## Uninstall and Destroy

First uninstall Jenkins, to do so `cd` into the `jenkins` folder and run:

```bash
kubectl delete -f .
```

Then delete the Kubernetes namespace created previously, for example:

```bash
kubectl delete namespace devops-tools
```

Next, uninstall the `backend` and `frontend` releases created with the Helm charts with the `helm uninstall` command. For example:

```bash
helm uninstall frontend
```

Then:

```bash
helm uninstall backend
```

Then destroy the AWS infrastructure with `terraform destroy`.
