# Contribute to improve these modules

To contribute to any of the modules follow these instructions:

1. Clone or fork the repository, this will get all the modules. Please, do not include code changes from other modules in a branch or pull request for a specific module.
2. Create a branch using the following naming convention: `(feat|fix|doc)/module/short_description`
   1. Prefix the branch name with `feat` for features, `fix` for fixes and `doc` for documentation changes. If you have other category let us know or use the closer existing one.
   2. The `module` section is the name of the module, for example: `roks`, `cp4mcm`,  `cp4app` or `cp4data`.
   3. This branch should be ONLY to make changes in one module. If there is an exception please, document it well and make sure there are no conflicts. Discuss and confirm with the modules owners the changes.
3. Set the IBM Cloud credentials as explained in the [Use](./README.md#Use) section of the README.
4. After changing the code, modify or add the required code validation to the unit test in the `testing` directory.
5. Run the unit tests moving to the `testing` folder and using `make` as explained in the [Testing](./README.md#Testing) section of the README and the README in the testing directory of each module.
6. Execute `terraform fmt -recursive` before commit the code.
7. If all the tests pass and you are ready to release the change, open a pull request:
   1. Name the PR similar to the branch, following the naming convention: `([FEATURE]|[FIX]|[DOC]) module: Short Description`, example: `[FEATURE] cp4data: update installer URL`
   2. Include the labels that applies to this PR
   3. Assign the PR to yourself
   4. If the PR is not ready to be merged, create it as a Draft
   5. Fill out all the required information in the PR description and add as much information as possible.
8. When the PR is ready to be merge, change it from Draft to Pull Request
9. Wait for the CI/CD to pass all the tests
10. Add the contributors or module owners as Reviewers
    1. Wait for them to review and approve the changes
    2. If there is any suggested change, apply the changes or discuss them in the branch comments
11. Merge the pull request

- [ ] _TODO: Include in the instructions the steps to follow if the developer is not a collaborator of the project_
- [ ] _TODO: Improve the instructions after the firsts contributions_
