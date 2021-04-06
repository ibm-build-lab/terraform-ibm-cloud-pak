# Contribute to improve these modules

To contribute to any of the modules follow these instructions:

1. Clone or fork the repository, this will get all the modules. Please, do not include code changes from other modules in a branch or pull request for a specific module.
2. Create a branch using the following naming convention: `(feat|fix|doc)/module/short_description`
   - Prefix the branch name with `feat` for features, `fix` for fixes and `doc` for documentation changes. If you have other category let us know or use the closer existing one.
   - The `module` section is the name of the module, for example: `roks`, `cp4mcm`,  `cp4app` or `cp4data`.
   - This branch should be ONLY to make changes in one module. If there is an exception please, document it well and make sure there are no conflicts. Discuss and confirm with the modules owners the changes.
3. Set the IBM Cloud credentials as explained [here](../CREDENTIALS.md).
4. After changing the code, modify or add the required code validation to the unit test in the module `testing` subdirectory.
5. To run the unit tests, go into the `testing` subdirectory and run `make` as explained in the [Testing](./README.md#Testing) section of the README and the README in the testing directory of each module.
6. Execute `terraform fmt -recursive` before committing the code.
7. If all the tests pass and you are ready to release the change, open a pull request:
   - Name the PR similar to the branch, following the naming convention: `([FEATURE]|[FIX]|[DOC]) module: Short Description`, example: `[FEATURE] cp4data: update installer URL`
   - Include the labels that apply to this PR
   - Assign the PR to yourself
   - If the PR is not ready to be merged, create it as a Draft
   -. Fill out all the required information in the PR description and add as much information as possible.
8. When the PR is ready to be merge, change it from Draft to Pull Request
9. Add the contributors or module owners as Reviewers
    - Wait for them to review and approve the changes
    - If there is any suggested change, apply the changes or discuss them in the branch comments
10. Merge the pull request

- [ ] _TODO: Include in the instructions the steps to follow if the developer is not a collaborator of the project_
