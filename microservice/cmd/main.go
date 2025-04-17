package main

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
)

var hostTypeMetric = prometheus.NewGaugeVec(
	prometheus.GaugeOpts{
		Name: "host_type_info",
		Help: "Type of the host: container, virtual_machine, or bare metal",
	},
	[]string{"type"},
)

type HostType string

var (
	HostTypeContainer      HostType = "container"
	HostTypeVirtualMachine HostType = "virtual_machine"
	HostTypeBareMetal      HostType = "bare_metal"
)

func initHostTypeMetric() {
	hostType := getHostType()
	hostTypeMetric.WithLabelValues(string(hostType)).Set(1)
	prometheus.MustRegister(hostTypeMetric)
}

func getHostType() HostType {
	if _, err := os.Stat("/.dockerenv"); err == nil {
		return HostTypeContainer
	}
	if data, err := os.ReadFile("/proc/1/cgroup"); err == nil {
		text := string(data)
		if strings.Contains(text, "docker") || strings.Contains(text, "lxc") || strings.Contains(text, "kubepods") {
			return HostTypeContainer
		}
	}

	out, err := exec.Command("systemd-detect-virt").Output()
	if err == nil {
		virt := strings.TrimSpace(string(out))

		// man systemd-detect-virt - чтобы посмотреть известные технологии виртуализации
		switch virt {
		case "qemu", "kvm", "amazon", "zvm", "vmware", "microsoft", "oracle", "powervm", "xen", "bochs", "uml", "parallels", "bhyve", "qnx":
			return HostTypeVirtualMachine
		case "openvz", "lxc", "lxc-libvirt", "systemd-nspawn", "docker", "podman", "rkt", "wsl", "proot", "pouch":
			return HostTypeContainer
		}
	}
	cpuinfo, err := os.ReadFile("/proc/cpuinfo")
	if err == nil {
		text := string(cpuinfo)
		if strings.Contains(text, "hypervisor") {
			return HostTypeVirtualMachine
		}
	}

	return HostTypeBareMetal // по умолчанию физический сервер
}

func main() {
	initHostTypeMetric()

	http.Handle("/", promhttp.Handler())

	log.Printf("Listening on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
