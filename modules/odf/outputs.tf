# Since terraform doesn't support whole module dependencies, if your module requires ODF to have been instantiated before creating other resources, create a variable in your module that is passed this output value.
# Make the ODF-dependent resources in your module dependent on that variable. The value is not relevant.


output "odf_is_ready" {
    description = "Check the ODF status"

    depends_on = [
      null_resource.enable_odf
    ]
    value = length(null_resource.enable_odf) > 0 ? null_resource.enable_odf[0].id : null
}