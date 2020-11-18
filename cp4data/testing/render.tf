locals {
  repo_content = templatefile("../templates/repo.yaml.tmpl", {
    entitled_registry_key                          = local.entitled_registry_key,
    docker_id                                      = local.docker_id,
    docker_access_token                            = local.docker_access_token,
    install_guardium_external_stap                 = local.install_guardium_external_stap,
    install_watson_assistant                       = local.install_watson_assistant,
    install_watson_assistant_for_voice_interaction = local.install_watson_assistant_for_voice_interaction,
    install_watson_discovery                       = local.install_watson_discovery,
    install_watson_knowledge_studio                = local.install_watson_knowledge_studio,
    install_watson_language_translator             = local.install_watson_language_translator,
    install_watson_speech_text                     = local.install_watson_speech_text,
    install_edge_analytics                         = local.install_edge_analytics,
  })
}

resource "local_file" "repo" {
  content  = local.repo_content
  filename = "${path.module}/rendered_files/repo.yaml"
}

locals {
  docker_id                                      = ""
  docker_access_token                            = ""
  install_guardium_external_stap                 = false
  install_watson_assistant                       = false
  install_watson_assistant_for_voice_interaction = false
  install_watson_discovery                       = false
  install_watson_knowledge_studio                = false
  install_watson_language_translator             = false
  install_watson_speech_text                     = false
  install_edge_analytics                         = false
}

