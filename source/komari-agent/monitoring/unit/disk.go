package monitoring

import (
	"github.com/shirou/gopsutil/disk"
	"fmt"
)

type DiskInfo struct {
	Total uint64 `json:"total"`
	Used  uint64 `json:"used"`
}

func Disk() DiskInfo {
	diskinfo := DiskInfo{}
	targetMounts := map[string]bool{
		"/":     true,
		"/boot": true,
	}

	partitions, err := disk.Partitions(false)
	if err != nil {
		return diskinfo
	}

	for _, part := range partitions {
		if !targetMounts[part.Mountpoint] {
			continue
		}

		u, err := disk.Usage(part.Mountpoint)
		if err != nil {
			continue
		}
		diskinfo.Total += u.Total
		diskinfo.Used += u.Used
	}

	return diskinfo
}
