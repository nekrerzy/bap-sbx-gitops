# bap-sbx-gitops

Throwaway GitOps repo for the BAP sandbox (personal subscription). Tests the path Terraform -> Argo CD extension ->
everything else, and public ingress through Application Gateway for Containers + WAF.
Laid out like the future `gitops/` folder of the platform repo. Delete after the test.

- `bootstrap/root.yaml`: applied once with kubectl; Argo CD then syncs `apps/`.
- `apps/`: one Argo CD Application per component.
- `workloads/echo/`: hello-world app published through the App Gateway, protected by the WAF policy.
