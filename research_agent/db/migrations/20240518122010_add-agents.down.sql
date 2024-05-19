-- MEMORIES
DROP INDEX IF EXISTS idx_mem_agent_embedding;
DROP TABLE IF EXISTS memories;
DROP TYPE IF EXISTS memory_type;

-- MEMORY PREDICATES
DROP INDEX IF EXISTS idx_pred_name;
DROP TABLE IF EXISTS memory_predicates;
DROP INDEX IF EXISTS idx_res_agent_rsrc_agent;
DROP INDEX IF EXISTS idx_res_agent_code;
DROP TABLE IF EXISTS resources;
DROP TYPE IF EXISTS resource_type;

-- JOB DEPENDEDNCIES
DROP INDEX IF EXISTS idx_dep_job_depends;
DROP TABLE IF EXISTS job_dependencies;

-- JOBS
DROP INDEX IF EXISTS idx_job_agent_name_reward;
DROP INDEX IF EXISTS idx_job_agent_name_poignancy;
DROP TABLE IF EXISTS jobs;
DROP TYPE IF EXISTS job_status;

-- SKILLS
DROP INDEX IF EXISTS id_skl_agent_code;
DROP INDEX IF EXISTS idx_skl_code_name;
DROP TABLE IF EXISTS skills;

-- AGENTS
DROP INDEX IF EXISTS idx_agt_agent_process;
DROP TABLE IF EXISTS agents;
DROP TYPE IF EXISTS agent_status;

-- AGENT PROCESSES
DROP INDEX IF EXISTS idx_prc_agent_type_code_name;
DROP INDEX IF EXISTS idx_prc_code_name;
DROP TABLE IF EXISTS agent_processes;
DROP TYPE IF EXISTS agent_type;