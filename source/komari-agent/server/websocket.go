package server

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/gorilla/websocket"
	"github.com/komari-monitor/komari-agent/cmd/flags"
	"github.com/komari-monitor/komari-agent/monitoring"
	"github.com/komari-monitor/komari-agent/terminal"
	"github.com/komari-monitor/komari-agent/ws"
)

func EstablishWebSocketConnection() {

	websocketEndpoint := strings.TrimSuffix(flags.Endpoint, "/") + "/api/clients/report?token=" + flags.Token
	websocketEndpoint = "ws" + strings.TrimPrefix(websocketEndpoint, "http")

	var conn *ws.SafeConn
	defer func() {
		if conn != nil {
			conn.Close()
		}
	}()
	var err error
	var interval float64
	if flags.Interval <= 1 {
		interval = 1
	} else {
		interval = flags.Interval - 1
	}

	ticker := time.NewTicker(time.Duration(interval * float64(time.Second)))
	defer ticker.Stop()

	for range ticker.C {
		// If no connection, attempt to connect
		if conn == nil {
			log.Println("Attempting to connect to WebSocket...")
			retry := 0
			for retry <= flags.MaxRetries {
				if retry > 0 {
					log.Println("Retrying websocket connection, attempt:", retry)
				}
				conn, err = connectWebSocket(websocketEndpoint)
				if err == nil {
					log.Println("WebSocket connected")
					go handleWebSocketMessages(conn, make(chan struct{}))
					break
				} else {
					log.Println("Failed to connect to WebSocket:", err)
				}
				retry++
				time.Sleep(time.Duration(flags.ReconnectInterval) * time.Second)
			}

			if retry > flags.MaxRetries {
				log.Println("Max retries reached.")
				return
			}
		}

		data := monitoring.GenerateReport()
		err = conn.WriteMessage(websocket.TextMessage, data)
		if err != nil {
			log.Println("Failed to send WebSocket message:", err)
			conn.Close()
			conn = nil // Mark connection as dead
			continue
		}
	}
}

func connectWebSocket(websocketEndpoint string) (*ws.SafeConn, error) {
	dialer := &websocket.Dialer{
		HandshakeTimeout: 5 * time.Second,
	}
	conn, resp, err := dialer.Dial(websocketEndpoint, nil)
	if err != nil {
		if resp != nil && resp.StatusCode != 101 {
			return nil, fmt.Errorf("%s", resp.Status)
		}
		return nil, err
	}

	return ws.NewSafeConn(conn), nil
}

func handleWebSocketMessages(conn *ws.SafeConn, done chan<- struct{}) {
	defer close(done)
	for {
		_, message_raw, err := conn.ReadMessage()
		if err != nil {
			log.Println("WebSocket read error:", err)
			return
		}
		var message struct {
			Message string `json:"message"`
			// Terminal
			TerminalId string `json:"request_id,omitempty"`
			// Remote Exec
			ExecCommand string `json:"command,omitempty"`
			ExecTaskID  string `json:"task_id,omitempty"`
			// Ping
			PingTaskID uint   `json:"ping_task_id,omitempty"`
			PingType   string `json:"ping_type,omitempty"`
			PingTarget string `json:"ping_target,omitempty"`
		}
		err = json.Unmarshal(message_raw, &message)
		if err != nil {
			log.Println("Bad ws message:", err)
			continue
		}

		if message.Message == "terminal" || message.TerminalId != "" {
			go establishTerminalConnection(flags.Token, message.TerminalId, flags.Endpoint)
			continue
		}
		if message.Message == "exec" {
			go NewTask(message.ExecTaskID, message.ExecCommand)
			continue
		}
		if message.Message == "ping" || message.PingTaskID != 0 || message.PingType != "" || message.PingTarget != "" {
			go NewPingTask(conn, message.PingTaskID, message.PingType, message.PingTarget)
			continue
		}
	}
}

// connectWebSocket attempts to establish a WebSocket connection and upload basic info

// establishTerminalConnection 建立终端连接并使用terminal包处理终端操作
func establishTerminalConnection(token, id, endpoint string) {
	endpoint = strings.TrimSuffix(endpoint, "/") + "/api/clients/terminal?token=" + token + "&id=" + id
	endpoint = "ws" + strings.TrimPrefix(endpoint, "http")
	dialer := &websocket.Dialer{
		HandshakeTimeout: 5 * time.Second,
	}
	conn, _, err := dialer.Dial(endpoint, nil)
	if err != nil {
		log.Println("Failed to establish terminal connection:", err)
		return
	}

	// 启动终端
	terminal.StartTerminal(conn)
	if conn != nil {
		conn.Close()
	}
}
