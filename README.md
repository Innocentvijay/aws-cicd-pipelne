# terraform-aws-codecommit-cicd
Terraform module that stands up a new AWS CodeCommit repository integrated with AWS CodePipeline. The CodePipeline consists of three stages:

1. A Source stage that is fed by the repository.
2. A Test stage that uses the artifacts of the Source and executes commands in `buildspec_test.yml`.
3. A Package stage that uses the artrifacts of the Test stage and excutes commands in `buildspec.yml`.



### CodeCommit Note
New repositories are **not** created with their default branch. Therefore, once the module has ran you must clone the repository, add a file, and then push to `origin/<repo_default_branch>` to initialize the repository.

Your command line execution might look something like this:

```bash
$>terraform apply
$>git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/my_repo
$>cd my_repo
$>echo 'hello world' > touch.txt
$>git add touch.txt
$>git commit -a -m 'init master'
$>git push -u origin master
$>git add buildspec_test.yml buildspec.yml #buildspec files push to code_commit repository(my_repo)
$>git commit -a -m 'init master'
$>git push -u origin master
```