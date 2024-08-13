import regex
import crds.v1beta2 as v1beta2

oxr = option("params").oxr
_ocds = option("params").ocds
_dxr = option("params").dxr
dcds = option("params").dcds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

get = lambda x: any, y: str, d: any -> any {
    """
    Get an item from a dictionary using a dot separated path.
    If the item is not found, return a default value.
    """
    p = regex.split(y, "\.")
    c = p[0]
    y = ".".join(p[1:])
    x[c] if len(p) == 1 and c in x else d if c not in x else get(x[c], y, d)
}

_defaults = {
    deletionPolicy: get(oxr, "spec.parameters.deletionPolicy", "Delete")
    forProvider.region: get(oxr, "spec.parameters.region", "us-west-2")
    providerConfigRef.name: get(oxr, "spec.providerConfigName", "default")
}

_items = []

_items += [ v1beta2.Bucket{
    metadata: _metadata("bucket")
    spec: _defaults
}]

_items += [ v1beta2.BucketVersioning {
    metadata: _metadata("bucketVersioning")
    spec: _defaults
    spec.forProvider:{
        bucketSelector: {
            matchControllerRef: True,
        }
        versioningConfiguration:{
            status: "Enabled"
        }
    }
} if get(oxr, "spec.parameters.versioning", "False") else {}]

items = [
    i for r in [_items]
    for i in r if i
]
