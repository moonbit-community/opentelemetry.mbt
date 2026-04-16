// DO NOT EDIT, this is an auto-generated file
//
// To update it, run:
// - node scripts/semconv_gen.js [path-to-opentelemetry-semantic-conventions]

///|
pub const ASPNETCORE_DIAGNOSTICS_EXCEPTIONS : String = "aspnetcore.diagnostics.exceptions"

///|
pub const ASPNETCORE_RATE_LIMITING_ACTIVE_REQUEST_LEASES : String = "aspnetcore.rate_limiting.active_request_leases"

///|
pub const ASPNETCORE_RATE_LIMITING_QUEUED_REQUESTS : String = "aspnetcore.rate_limiting.queued_requests"

///|
pub const ASPNETCORE_RATE_LIMITING_REQUEST_TIME_IN_QUEUE : String = "aspnetcore.rate_limiting.request.time_in_queue"

///|
pub const ASPNETCORE_RATE_LIMITING_REQUEST_LEASE_DURATION : String = "aspnetcore.rate_limiting.request_lease.duration"

///|
pub const ASPNETCORE_RATE_LIMITING_REQUESTS : String = "aspnetcore.rate_limiting.requests"

///|
pub const ASPNETCORE_ROUTING_MATCH_ATTEMPTS : String = "aspnetcore.routing.match_attempts"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const AZURE_COSMOSDB_CLIENT_ACTIVE_INSTANCE_COUNT : String = "azure.cosmosdb.client.active_instance.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const AZURE_COSMOSDB_CLIENT_OPERATION_REQUEST_CHARGE : String = "azure.cosmosdb.client.operation.request_charge"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CICD_PIPELINE_RUN_ACTIVE : String = "cicd.pipeline.run.active"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CICD_PIPELINE_RUN_DURATION : String = "cicd.pipeline.run.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CICD_PIPELINE_RUN_ERRORS : String = "cicd.pipeline.run.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CICD_SYSTEM_ERRORS : String = "cicd.system.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CICD_WORKER_COUNT : String = "cicd.worker.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_CPU_TIME : String = "container.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_CPU_USAGE : String = "container.cpu.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_DISK_IO : String = "container.disk.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_MEMORY_USAGE : String = "container.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_NETWORK_IO : String = "container.network.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CONTAINER_UPTIME : String = "container.uptime"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const CPU_FREQUENCY : String = "cpu.frequency"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const CPU_TIME : String = "cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const CPU_UTILIZATION : String = "cpu.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CPYTHON_GC_COLLECTED_OBJECTS : String = "cpython.gc.collected_objects"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CPYTHON_GC_COLLECTIONS : String = "cpython.gc.collections"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const CPYTHON_GC_UNCOLLECTABLE_OBJECTS : String = "cpython.gc.uncollectable_objects"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_COUNT : String = "db.client.connection.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_CREATE_TIME : String = "db.client.connection.create_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_IDLE_MAX : String = "db.client.connection.idle.max"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_IDLE_MIN : String = "db.client.connection.idle.min"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_MAX : String = "db.client.connection.max"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_PENDING_REQUESTS : String = "db.client.connection.pending_requests"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_TIMEOUTS : String = "db.client.connection.timeouts"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_USE_TIME : String = "db.client.connection.use_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_CONNECTION_WAIT_TIME : String = "db.client.connection.wait_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_CREATE_TIME : String = "db.client.connections.create_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_IDLE_MAX : String = "db.client.connections.idle.max"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_IDLE_MIN : String = "db.client.connections.idle.min"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_MAX : String = "db.client.connections.max"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_PENDING_REQUESTS : String = "db.client.connections.pending_requests"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_TIMEOUTS : String = "db.client.connections.timeouts"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_USAGE : String = "db.client.connections.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_USE_TIME : String = "db.client.connections.use_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_CONNECTIONS_WAIT_TIME : String = "db.client.connections.wait_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_COSMOSDB_ACTIVE_INSTANCE_COUNT : String = "db.client.cosmosdb.active_instance.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const DB_CLIENT_COSMOSDB_OPERATION_REQUEST_CHARGE : String = "db.client.cosmosdb.operation.request_charge"

///|
pub const DB_CLIENT_OPERATION_DURATION : String = "db.client.operation.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DB_CLIENT_RESPONSE_RETURNED_ROWS : String = "db.client.response.returned_rows"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const DNS_LOOKUP_DURATION : String = "dns.lookup.duration"

///|
pub const DOTNET_ASSEMBLY_COUNT : String = "dotnet.assembly.count"

///|
pub const DOTNET_EXCEPTIONS : String = "dotnet.exceptions"

///|
pub const DOTNET_GC_COLLECTIONS : String = "dotnet.gc.collections"

///|
pub const DOTNET_GC_HEAP_TOTAL_ALLOCATED : String = "dotnet.gc.heap.total_allocated"

///|
pub const DOTNET_GC_LAST_COLLECTION_HEAP_FRAGMENTATION_SIZE : String = "dotnet.gc.last_collection.heap.fragmentation.size"

///|
pub const DOTNET_GC_LAST_COLLECTION_HEAP_SIZE : String = "dotnet.gc.last_collection.heap.size"

///|
pub const DOTNET_GC_LAST_COLLECTION_MEMORY_COMMITTED_SIZE : String = "dotnet.gc.last_collection.memory.committed_size"

///|
pub const DOTNET_GC_PAUSE_TIME : String = "dotnet.gc.pause.time"

///|
pub const DOTNET_JIT_COMPILATION_TIME : String = "dotnet.jit.compilation.time"

///|
pub const DOTNET_JIT_COMPILED_IL_SIZE : String = "dotnet.jit.compiled_il.size"

///|
pub const DOTNET_JIT_COMPILED_METHODS : String = "dotnet.jit.compiled_methods"

///|
pub const DOTNET_MONITOR_LOCK_CONTENTIONS : String = "dotnet.monitor.lock_contentions"

///|
pub const DOTNET_PROCESS_CPU_COUNT : String = "dotnet.process.cpu.count"

///|
pub const DOTNET_PROCESS_CPU_TIME : String = "dotnet.process.cpu.time"

///|
pub const DOTNET_PROCESS_MEMORY_WORKING_SET : String = "dotnet.process.memory.working_set"

///|
pub const DOTNET_THREAD_POOL_QUEUE_LENGTH : String = "dotnet.thread_pool.queue.length"

///|
pub const DOTNET_THREAD_POOL_THREAD_COUNT : String = "dotnet.thread_pool.thread.count"

///|
pub const DOTNET_THREAD_POOL_WORK_ITEM_COUNT : String = "dotnet.thread_pool.work_item.count"

///|
pub const DOTNET_TIMER_COUNT : String = "dotnet.timer.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_COLDSTARTS : String = "faas.coldstarts"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_CPU_USAGE : String = "faas.cpu_usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_ERRORS : String = "faas.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_INIT_DURATION : String = "faas.init_duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_INVOCATIONS : String = "faas.invocations"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_INVOKE_DURATION : String = "faas.invoke_duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_MEM_USAGE : String = "faas.mem_usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_NET_IO : String = "faas.net_io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const FAAS_TIMEOUTS : String = "faas.timeouts"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GEN_AI_CLIENT_OPERATION_DURATION : String = "gen_ai.client.operation.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GEN_AI_CLIENT_TOKEN_USAGE : String = "gen_ai.client.token.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GEN_AI_SERVER_REQUEST_DURATION : String = "gen_ai.server.request.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GEN_AI_SERVER_TIME_PER_OUTPUT_TOKEN : String = "gen_ai.server.time_per_output_token"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GEN_AI_SERVER_TIME_TO_FIRST_TOKEN : String = "gen_ai.server.time_to_first_token"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_CONFIG_GOGC : String = "go.config.gogc"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_GOROUTINE_COUNT : String = "go.goroutine.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_MEMORY_ALLOCATED : String = "go.memory.allocated"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_MEMORY_ALLOCATIONS : String = "go.memory.allocations"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_MEMORY_GC_GOAL : String = "go.memory.gc.goal"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_MEMORY_LIMIT : String = "go.memory.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_MEMORY_USED : String = "go.memory.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_PROCESSOR_LIMIT : String = "go.processor.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const GO_SCHEDULE_DURATION : String = "go.schedule.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_CLIENT_ACTIVE_REQUESTS : String = "http.client.active_requests"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_CLIENT_CONNECTION_DURATION : String = "http.client.connection.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_CLIENT_OPEN_CONNECTIONS : String = "http.client.open_connections"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_CLIENT_REQUEST_BODY_SIZE : String = "http.client.request.body.size"

///|
pub const HTTP_CLIENT_REQUEST_DURATION : String = "http.client.request.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_CLIENT_RESPONSE_BODY_SIZE : String = "http.client.response.body.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_SERVER_ACTIVE_REQUESTS : String = "http.server.active_requests"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_SERVER_REQUEST_BODY_SIZE : String = "http.server.request.body.size"

///|
pub const HTTP_SERVER_REQUEST_DURATION : String = "http.server.request.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HTTP_SERVER_RESPONSE_BODY_SIZE : String = "http.server.response.body.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_ENERGY : String = "hw.energy"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_ERRORS : String = "hw.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_HOST_AMBIENT_TEMPERATURE : String = "hw.host.ambient_temperature"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_HOST_ENERGY : String = "hw.host.energy"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_HOST_HEATING_MARGIN : String = "hw.host.heating_margin"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_HOST_POWER : String = "hw.host.power"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_POWER : String = "hw.power"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const HW_STATUS : String = "hw.status"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_BUFFER_COUNT : String = "jvm.buffer.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_BUFFER_MEMORY_LIMIT : String = "jvm.buffer.memory.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const JVM_BUFFER_MEMORY_USAGE : String = "jvm.buffer.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_BUFFER_MEMORY_USED : String = "jvm.buffer.memory.used"

///|
pub const JVM_CLASS_COUNT : String = "jvm.class.count"

///|
pub const JVM_CLASS_LOADED : String = "jvm.class.loaded"

///|
pub const JVM_CLASS_UNLOADED : String = "jvm.class.unloaded"

///|
pub const JVM_CPU_COUNT : String = "jvm.cpu.count"

///|
pub const JVM_CPU_RECENT_UTILIZATION : String = "jvm.cpu.recent_utilization"

///|
pub const JVM_CPU_TIME : String = "jvm.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_FILE_DESCRIPTOR_COUNT : String = "jvm.file_descriptor.count"

///|
pub const JVM_GC_DURATION : String = "jvm.gc.duration"

///|
pub const JVM_MEMORY_COMMITTED : String = "jvm.memory.committed"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_MEMORY_INIT : String = "jvm.memory.init"

///|
pub const JVM_MEMORY_LIMIT : String = "jvm.memory.limit"

///|
pub const JVM_MEMORY_USED : String = "jvm.memory.used"

///|
pub const JVM_MEMORY_USED_AFTER_LAST_GC : String = "jvm.memory.used_after_last_gc"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_SYSTEM_CPU_LOAD_1M : String = "jvm.system.cpu.load_1m"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const JVM_SYSTEM_CPU_UTILIZATION : String = "jvm.system.cpu.utilization"

///|
pub const JVM_THREAD_COUNT : String = "jvm.thread.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_CPU_LIMIT : String = "k8s.container.cpu.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_CPU_REQUEST : String = "k8s.container.cpu.request"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_EPHEMERAL_STORAGE_LIMIT : String = "k8s.container.ephemeral_storage.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_EPHEMERAL_STORAGE_REQUEST : String = "k8s.container.ephemeral_storage.request"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_MEMORY_LIMIT : String = "k8s.container.memory.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_MEMORY_REQUEST : String = "k8s.container.memory.request"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_READY : String = "k8s.container.ready"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_RESTART_COUNT : String = "k8s.container.restart.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_STATUS_REASON : String = "k8s.container.status.reason"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_STATUS_STATE : String = "k8s.container.status.state"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_STORAGE_LIMIT : String = "k8s.container.storage.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CONTAINER_STORAGE_REQUEST : String = "k8s.container.storage.request"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_CRONJOB_ACTIVE_JOBS : String = "k8s.cronjob.active_jobs"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DAEMONSET_CURRENT_SCHEDULED_NODES : String = "k8s.daemonset.current_scheduled_nodes"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DAEMONSET_DESIRED_SCHEDULED_NODES : String = "k8s.daemonset.desired_scheduled_nodes"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DAEMONSET_MISSCHEDULED_NODES : String = "k8s.daemonset.misscheduled_nodes"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DAEMONSET_READY_NODES : String = "k8s.daemonset.ready_nodes"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DEPLOYMENT_AVAILABLE_PODS : String = "k8s.deployment.available_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_DEPLOYMENT_DESIRED_PODS : String = "k8s.deployment.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_CURRENT_PODS : String = "k8s.hpa.current_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_DESIRED_PODS : String = "k8s.hpa.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_MAX_PODS : String = "k8s.hpa.max_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_METRIC_TARGET_CPU_AVERAGE_UTILIZATION : String = "k8s.hpa.metric.target.cpu.average_utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_METRIC_TARGET_CPU_AVERAGE_VALUE : String = "k8s.hpa.metric.target.cpu.average_value"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_METRIC_TARGET_CPU_VALUE : String = "k8s.hpa.metric.target.cpu.value"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_HPA_MIN_PODS : String = "k8s.hpa.min_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_JOB_ACTIVE_PODS : String = "k8s.job.active_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_JOB_DESIRED_SUCCESSFUL_PODS : String = "k8s.job.desired_successful_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_JOB_FAILED_PODS : String = "k8s.job.failed_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_JOB_MAX_PARALLEL_PODS : String = "k8s.job.max_parallel_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_JOB_SUCCESSFUL_PODS : String = "k8s.job.successful_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NAMESPACE_PHASE : String = "k8s.namespace.phase"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_ALLOCATABLE_CPU : String = "k8s.node.allocatable.cpu"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_ALLOCATABLE_EPHEMERAL_STORAGE : String = "k8s.node.allocatable.ephemeral_storage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_ALLOCATABLE_MEMORY : String = "k8s.node.allocatable.memory"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_ALLOCATABLE_PODS : String = "k8s.node.allocatable.pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_CONDITION_STATUS : String = "k8s.node.condition.status"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_CPU_TIME : String = "k8s.node.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_CPU_USAGE : String = "k8s.node.cpu.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_MEMORY_USAGE : String = "k8s.node.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_NETWORK_ERRORS : String = "k8s.node.network.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_NETWORK_IO : String = "k8s.node.network.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_NODE_UPTIME : String = "k8s.node.uptime"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_CPU_TIME : String = "k8s.pod.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_CPU_USAGE : String = "k8s.pod.cpu.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_MEMORY_USAGE : String = "k8s.pod.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_NETWORK_ERRORS : String = "k8s.pod.network.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_NETWORK_IO : String = "k8s.pod.network.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_POD_UPTIME : String = "k8s.pod.uptime"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_REPLICASET_AVAILABLE_PODS : String = "k8s.replicaset.available_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_REPLICASET_DESIRED_PODS : String = "k8s.replicaset.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const K8S_REPLICATION_CONTROLLER_AVAILABLE_PODS : String = "k8s.replication_controller.available_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const K8S_REPLICATION_CONTROLLER_DESIRED_PODS : String = "k8s.replication_controller.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_REPLICATIONCONTROLLER_AVAILABLE_PODS : String = "k8s.replicationcontroller.available_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_REPLICATIONCONTROLLER_DESIRED_PODS : String = "k8s.replicationcontroller.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_CPU_LIMIT_HARD : String = "k8s.resourcequota.cpu.limit.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_CPU_LIMIT_USED : String = "k8s.resourcequota.cpu.limit.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_CPU_REQUEST_HARD : String = "k8s.resourcequota.cpu.request.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_CPU_REQUEST_USED : String = "k8s.resourcequota.cpu.request.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_EPHEMERAL_STORAGE_LIMIT_HARD : String = "k8s.resourcequota.ephemeral_storage.limit.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_EPHEMERAL_STORAGE_LIMIT_USED : String = "k8s.resourcequota.ephemeral_storage.limit.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_EPHEMERAL_STORAGE_REQUEST_HARD : String = "k8s.resourcequota.ephemeral_storage.request.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_EPHEMERAL_STORAGE_REQUEST_USED : String = "k8s.resourcequota.ephemeral_storage.request.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_HUGEPAGE_COUNT_REQUEST_HARD : String = "k8s.resourcequota.hugepage_count.request.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_HUGEPAGE_COUNT_REQUEST_USED : String = "k8s.resourcequota.hugepage_count.request.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_MEMORY_LIMIT_HARD : String = "k8s.resourcequota.memory.limit.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_MEMORY_LIMIT_USED : String = "k8s.resourcequota.memory.limit.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_MEMORY_REQUEST_HARD : String = "k8s.resourcequota.memory.request.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_MEMORY_REQUEST_USED : String = "k8s.resourcequota.memory.request.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_OBJECT_COUNT_HARD : String = "k8s.resourcequota.object_count.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_OBJECT_COUNT_USED : String = "k8s.resourcequota.object_count.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_PERSISTENTVOLUMECLAIM_COUNT_HARD : String = "k8s.resourcequota.persistentvolumeclaim_count.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_PERSISTENTVOLUMECLAIM_COUNT_USED : String = "k8s.resourcequota.persistentvolumeclaim_count.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_STORAGE_REQUEST_HARD : String = "k8s.resourcequota.storage.request.hard"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_RESOURCEQUOTA_STORAGE_REQUEST_USED : String = "k8s.resourcequota.storage.request.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_STATEFULSET_CURRENT_PODS : String = "k8s.statefulset.current_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_STATEFULSET_DESIRED_PODS : String = "k8s.statefulset.desired_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_STATEFULSET_READY_PODS : String = "k8s.statefulset.ready_pods"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const K8S_STATEFULSET_UPDATED_PODS : String = "k8s.statefulset.updated_pods"

///|
pub const KESTREL_ACTIVE_CONNECTIONS : String = "kestrel.active_connections"

///|
pub const KESTREL_ACTIVE_TLS_HANDSHAKES : String = "kestrel.active_tls_handshakes"

///|
pub const KESTREL_CONNECTION_DURATION : String = "kestrel.connection.duration"

///|
pub const KESTREL_QUEUED_CONNECTIONS : String = "kestrel.queued_connections"

///|
pub const KESTREL_QUEUED_REQUESTS : String = "kestrel.queued_requests"

///|
pub const KESTREL_REJECTED_CONNECTIONS : String = "kestrel.rejected_connections"

///|
pub const KESTREL_TLS_HANDSHAKE_DURATION : String = "kestrel.tls_handshake.duration"

///|
pub const KESTREL_UPGRADED_CONNECTIONS : String = "kestrel.upgraded_connections"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const MESSAGING_CLIENT_CONSUMED_MESSAGES : String = "messaging.client.consumed.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const MESSAGING_CLIENT_OPERATION_DURATION : String = "messaging.client.operation.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_CLIENT_PUBLISHED_MESSAGES : String = "messaging.client.published.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const MESSAGING_CLIENT_SENT_MESSAGES : String = "messaging.client.sent.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const MESSAGING_PROCESS_DURATION : String = "messaging.process.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_PROCESS_MESSAGES : String = "messaging.process.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_PUBLISH_DURATION : String = "messaging.publish.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_PUBLISH_MESSAGES : String = "messaging.publish.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_RECEIVE_DURATION : String = "messaging.receive.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const MESSAGING_RECEIVE_MESSAGES : String = "messaging.receive.messages"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_MAX : String = "nodejs.eventloop.delay.max"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_MEAN : String = "nodejs.eventloop.delay.mean"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_MIN : String = "nodejs.eventloop.delay.min"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_P50 : String = "nodejs.eventloop.delay.p50"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_P90 : String = "nodejs.eventloop.delay.p90"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_P99 : String = "nodejs.eventloop.delay.p99"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_DELAY_STDDEV : String = "nodejs.eventloop.delay.stddev"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_TIME : String = "nodejs.eventloop.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const NODEJS_EVENTLOOP_UTILIZATION : String = "nodejs.eventloop.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_LOG_EXPORTED : String = "otel.sdk.exporter.log.exported"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_LOG_INFLIGHT : String = "otel.sdk.exporter.log.inflight"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_METRIC_DATA_POINT_EXPORTED : String = "otel.sdk.exporter.metric_data_point.exported"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_METRIC_DATA_POINT_INFLIGHT : String = "otel.sdk.exporter.metric_data_point.inflight"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_OPERATION_DURATION : String = "otel.sdk.exporter.operation.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_SPAN_EXPORTED : String = "otel.sdk.exporter.span.exported"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const OTEL_SDK_EXPORTER_SPAN_EXPORTED_COUNT : String = "otel.sdk.exporter.span.exported.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_EXPORTER_SPAN_INFLIGHT : String = "otel.sdk.exporter.span.inflight"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const OTEL_SDK_EXPORTER_SPAN_INFLIGHT_COUNT : String = "otel.sdk.exporter.span.inflight.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_LOG_CREATED : String = "otel.sdk.log.created"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_METRIC_READER_COLLECTION_DURATION : String = "otel.sdk.metric_reader.collection.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_LOG_PROCESSED : String = "otel.sdk.processor.log.processed"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_LOG_QUEUE_CAPACITY : String = "otel.sdk.processor.log.queue.capacity"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_LOG_QUEUE_SIZE : String = "otel.sdk.processor.log.queue.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_SPAN_PROCESSED : String = "otel.sdk.processor.span.processed"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_SPAN_PROCESSED_COUNT : String = "otel.sdk.processor.span.processed.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_SPAN_QUEUE_CAPACITY : String = "otel.sdk.processor.span.queue.capacity"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_PROCESSOR_SPAN_QUEUE_SIZE : String = "otel.sdk.processor.span.queue.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: {note: Obsoleted., reason: obsoleted}
pub const OTEL_SDK_SPAN_ENDED : String = "otel.sdk.span.ended"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: {note: Obsoleted., reason: obsoleted}
pub const OTEL_SDK_SPAN_ENDED_COUNT : String = "otel.sdk.span.ended.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_SPAN_LIVE : String = "otel.sdk.span.live"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const OTEL_SDK_SPAN_LIVE_COUNT : String = "otel.sdk.span.live.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const OTEL_SDK_SPAN_STARTED : String = "otel.sdk.span.started"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_CONTEXT_SWITCHES : String = "process.context_switches"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_CPU_TIME : String = "process.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_CPU_UTILIZATION : String = "process.cpu.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_DISK_IO : String = "process.disk.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_MEMORY_USAGE : String = "process.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_MEMORY_VIRTUAL : String = "process.memory.virtual"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_NETWORK_IO : String = "process.network.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_OPEN_FILE_DESCRIPTOR_COUNT : String = "process.open_file_descriptor.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_PAGING_FAULTS : String = "process.paging.faults"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_THREAD_COUNT : String = "process.thread.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const PROCESS_UPTIME : String = "process.uptime"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_CLIENT_DURATION : String = "rpc.client.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_CLIENT_REQUEST_SIZE : String = "rpc.client.request.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_CLIENT_REQUESTS_PER_RPC : String = "rpc.client.requests_per_rpc"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_CLIENT_RESPONSE_SIZE : String = "rpc.client.response.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_CLIENT_RESPONSES_PER_RPC : String = "rpc.client.responses_per_rpc"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_SERVER_DURATION : String = "rpc.server.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_SERVER_REQUEST_SIZE : String = "rpc.server.request.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_SERVER_REQUESTS_PER_RPC : String = "rpc.server.requests_per_rpc"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_SERVER_RESPONSE_SIZE : String = "rpc.server.response.size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const RPC_SERVER_RESPONSES_PER_RPC : String = "rpc.server.responses_per_rpc"

///|
pub const SIGNALR_SERVER_ACTIVE_CONNECTIONS : String = "signalr.server.active_connections"

///|
pub const SIGNALR_SERVER_CONNECTION_DURATION : String = "signalr.server.connection.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_CPU_FREQUENCY : String = "system.cpu.frequency"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_CPU_LOGICAL_COUNT : String = "system.cpu.logical.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_CPU_PHYSICAL_COUNT : String = "system.cpu.physical.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_CPU_TIME : String = "system.cpu.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_CPU_UTILIZATION : String = "system.cpu.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_IO : String = "system.disk.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_IO_TIME : String = "system.disk.io_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_LIMIT : String = "system.disk.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_MERGED : String = "system.disk.merged"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_OPERATION_TIME : String = "system.disk.operation_time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_DISK_OPERATIONS : String = "system.disk.operations"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_FILESYSTEM_LIMIT : String = "system.filesystem.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_FILESYSTEM_USAGE : String = "system.filesystem.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_FILESYSTEM_UTILIZATION : String = "system.filesystem.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_LINUX_MEMORY_AVAILABLE : String = "system.linux.memory.available"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_LINUX_MEMORY_SLAB_USAGE : String = "system.linux.memory.slab.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_MEMORY_LIMIT : String = "system.memory.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_MEMORY_SHARED : String = "system.memory.shared"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_MEMORY_USAGE : String = "system.memory.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_MEMORY_UTILIZATION : String = "system.memory.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_NETWORK_CONNECTION_COUNT : String = "system.network.connection.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
/// Deprecated in the upstream Rust crate: Deprecated in upstream Rust crate.
pub const SYSTEM_NETWORK_CONNECTIONS : String = "system.network.connections"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_NETWORK_DROPPED : String = "system.network.dropped"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_NETWORK_ERRORS : String = "system.network.errors"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_NETWORK_IO : String = "system.network.io"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_NETWORK_PACKETS : String = "system.network.packets"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PAGING_FAULTS : String = "system.paging.faults"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PAGING_OPERATIONS : String = "system.paging.operations"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PAGING_USAGE : String = "system.paging.usage"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PAGING_UTILIZATION : String = "system.paging.utilization"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PROCESS_COUNT : String = "system.process.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_PROCESS_CREATED : String = "system.process.created"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const SYSTEM_UPTIME : String = "system.uptime"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const V8JS_GC_DURATION : String = "v8js.gc.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const V8JS_HEAP_SPACE_AVAILABLE_SIZE : String = "v8js.heap.space.available_size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const V8JS_HEAP_SPACE_PHYSICAL_SIZE : String = "v8js.heap.space.physical_size"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const V8JS_MEMORY_HEAP_LIMIT : String = "v8js.memory.heap.limit"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const V8JS_MEMORY_HEAP_USED : String = "v8js.memory.heap.used"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_CHANGE_COUNT : String = "vcs.change.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_CHANGE_DURATION : String = "vcs.change.duration"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_CHANGE_TIME_TO_APPROVAL : String = "vcs.change.time_to_approval"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_CHANGE_TIME_TO_MERGE : String = "vcs.change.time_to_merge"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_CONTRIBUTOR_COUNT : String = "vcs.contributor.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_REF_COUNT : String = "vcs.ref.count"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_REF_LINES_DELTA : String = "vcs.ref.lines_delta"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_REF_REVISIONS_DELTA : String = "vcs.ref.revisions_delta"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_REF_TIME : String = "vcs.ref.time"

///|
/// Experimental semantic convention in the upstream Rust crate.
pub const VCS_REPOSITORY_COUNT : String = "vcs.repository.count"
