package tectonicutility

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

const (
	// Kind is the TypeMeta.Kind for the OperatorConfig.
	Kind = "TectonicUtilityOperatorConfig"
	// APIVersion is the TypeMeta.APIVersion for the OperatorConfig.
	APIVersion = "v1"
)

// OperatorConfig defines the config for Tectonic Utility Operator.
type OperatorConfig struct {
	metav1.TypeMeta    `json:",inline"`
	StatsEmitterConfig `json:"statsEmitterConfig"`
	NetworkConfig      `json:"networkConfig"`
}

// StatsEmitterConfig defines the config for Tectonic Stats Emitter.
type StatsEmitterConfig struct {
	StatsURL string `json:"statsURL"`
}

// NetworkConfig holds information on cluster networking.
// Copied from kube-core
type NetworkConfig struct {
	AdvertiseAddress string `json:"advertise_address"`
	ClusterCIDR      string `json:"cluster_cidr"`
	EtcdServers      string `json:"etcd_servers"`
	ServiceCIDR      string `json:"service_cidr"`
}
