-- AGENT PROCESSES
CREATE TYPE agent_type AS ENUM (
	-- Research
	'research_dept_head',
	'research_manager',
	'research_analyst',
	-- Product
	'product_dept_head',
	'product_manager',
	'product_assistant',
	-- Design
	'designer_dept_head',
	'designer_manager',
	'designer_assistant',
	-- Engineering
	'data_dept_head',
	'data_manager',
	'data_scientist',
	'eng_dept_head',
	'eng_manager',
	'eng_engineer',
	'devops_dept_head',
	'devops_manager',
	'devops_engineer',
	-- Leadershp
	'ceo',
	'cto',
	'cfo',
	'coo',
	'cpo',
	-- Advisors
	'advisor_technical',
	'advisor_product',
	'advisor_design',
	'advisor_marketing',
	'advisor_sales',
	'advisor_legal'
);
CREATE TABLE IF NOT EXISTS processes (
	id varchar(64) NOT NULL DEFAULT CONCAT('prc_', ksuid_pgcrypto()) PRIMARY KEY,
	code_name varchar(32) NOT NULL,
	agent_type varchar(32) NOT NULL,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	description jsonb NOT NULL DEFAULT '{}'::jsonb,
	schema jsonb NOT NULL DEFAULT '{}'::jsonb,
	last_completed_step INT NOT NULL DEFAULT 0
);
-- Ensure that processes have unique code_names
CREATE UNIQUE INDEX IF NOT EXISTS idx_prc_code_name ON processes(code_name);
-- Ensure that processes have unique agent_types for a given code_name
CREATE UNIQUE INDEX IF NOT EXISTS idx_prc_agent_type_code_name ON processes(code_name, agent_type);

-- AGENTS
CREATE TYPE agent_status AS ENUM (
	'idle',
	-- self management
	'thinking',
	'planning',
	'executing',
	'getting_help', 
	-- interacting with other agents
	'blocked',
	'meeting',
	'helping',
	'getting_approval'
);
CREATE TABLE IF NOT EXISTS agents (
  	id varchar(64) NOT NULL DEFAULT CONCAT('agt_', ksuid_pgcrypto()) PRIMARY KEY,
	rank INT NOT NULL DEFAULT 0,
	boss_agent_id varchar(64),
	agent_type agent_type NOT NULL,
	process_id varchar(64),
  	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
  	title varchar(32) NOT NULL,
  	job_desc jsonb NOT NULL DEFAULT '{}'::jsonb,
  	background_desc jsonb NOT NULL DEFAULT '{}'::jsonb,
	reactivity_bias INT NOT NULL DEFAULT 0,
	perspective_bias INT NOT NULL DEFAULT 0,
	collaboration_bias INT NOT NULL DEFAULT 0,
	poignancy_score INT NOT NULL DEFAULT 0,
	reward_score INT NOT NULL DEFAULT 0,
	status agent_status NOT NULL DEFAULT 'idle',

	CONSTRAINT fk_boss_agent_id FOREIGN KEY (boss_agent_id) REFERENCES agents(id)
);
-- Ensure that there's never duplicate agent's doing the same thing.
CREATE UNIQUE INDEX IF NOT EXISTS idx_agt_agent_process ON agents(process_id, title);

-- CHECK AGENT RANK
CREATE OR REPLACE FUNCTION check_agent_rank() RETURNS TRIGGER AS $$
BEGIN
	IF NEW.boss_agent_id IS NOT NULL THEN
		IF NEW.rank >= (SELECT rank FROM agents WHERE id = NEW.boss_agent_id) THEN
			RAISE EXCEPTION 'Agent rank must be less than boss agent rank';
		END IF;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER agent_rank_trigger
BEFORE INSERT OR UPDATE ON agents
FOR EACH ROW EXECUTE FUNCTION check_agent_rank();

-- SKILLS
CREATE TABLE IF NOT EXISTS skills (
	id varchar(64) NOT NULL DEFAULT CONCAT('skl_', ksuid_pgcrypto()) PRIMARY KEY,
	agent_id varchar(64) NOT NULL,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	code_name varchar(32) NOT NULL,
	description jsonb NOT NULL DEFAULT '{}'::jsonb,
	schema jsonb NOT NULL DEFAULT '{}'::jsonb,
	
	CONSTRAINT fk_agent_id FOREIGN KEY (agent_id) REFERENCES agents(id)
);
-- Ensure that skills are uniquely named
CREATE UNIQUE INDEX IF NOT EXISTS idx_skl_code_name ON skills(code_name);
-- Ensure that agent's have unique skills
CREATE UNIQUE INDEX IF NOT EXISTS idx_skl_agent_code ON skills(code_name, agent_id); 

-- JOBS
CREATE TYPE job_status AS ENUM ('backlog', 'blocked', 'in_progress', 'cancelled', 'completed', 'failed');

CREATE TABLE IF NOT EXISTS jobs (
	id varchar(64) NOT NULL DEFAULT CONCAT('job_', ksuid_pgcrypto()) PRIMARY KEY,
	agent_id varchar(64) NOT NULL,
	skill_id varchar(64),
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	name varchar(32) NOT NULL,
	description jsonb NOT NULL DEFAULT '{}'::jsonb,
	schema jsonb NOT NULL DEFAULT '{}'::jsonb,
	poignancy INT NOT NULL DEFAULT 0,
	reward INT NOT NULL DEFAULT 0,
	approved BOOLEAN NOT NULL DEFAULT FALSE,
	status job_status NOT NULL DEFAULT 'backlog',

	CONSTRAINT fk_agent_id FOREIGN KEY (agent_id) REFERENCES agents(id),
	CONSTRAINT fk_skill_id FOREIGN KEY (skill_id) REFERENCES skills(id)
);
-- Ensure that agent's cannot have duplicate jobs with the same poignancy. Jobs should have varying levels of poignancy to ensure that agents are not having to choose from multiple jobs with the same poignancy value, and possibly choose the wrong one.
CREATE UNIQUE INDEX IF NOT EXISTS idx_job_agent_name_poignancy ON jobs(name, agent_id, poignancy);
-- Ensure that agent's cannot have duplicate jobs with the same reward. Jobs should have varying levels of reward to ensure that agents are not having to choose from multiple jobs with the same reward value, and possibly choose the wrong one.
CREATE UNIQUE INDEX IF NOT EXISTS idx_job_agent_name_reward ON jobs(name, agent_id, reward);

-- JOB DEPENDENCIES
CREATE TABLE IF NOT EXISTS job_dependencies (
	id varchar(64) NOT NULL DEFAULT CONCAT('dep_', ksuid_pgcrypto()) PRIMARY KEY,
	job_id varchar(64) NOT NULL,
	depends_on_job_id varchar(64) NOT NULL,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	
	CONSTRAINT fk_job_id FOREIGN KEY (job_id) REFERENCES jobs(id),
	CONSTRAINT fk_depends_on_job_id FOREIGN KEY (depends_on_job_id) REFERENCES jobs(id)
);
-- Ensure that job dependencies are unique: We don't create multiple edges between the same two job nodes.
CREATE UNIQUE INDEX IF NOT EXISTS idx_dep_job_depends ON job_dependencies(job_id, depends_on_job_id);

-- RESOURCES
CREATE TYPE resource_type AS ENUM (
	'human',
	'agent',
	'reference'
);
CREATE TABLE IF NOT EXISTS resources (
	id varchar(64) NOT NULL DEFAULT CONCAT('rsrc_', ksuid_pgcrypto()) PRIMARY KEY,
	agent_id varchar(64) NOT NULL,
	type resource_type NOT NULL,
	rsrc_agent_id varchar(64),
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	code_name varchar(32) NOT NULL,
	description jsonb NOT NULL DEFAULT '{}'::jsonb,
	schema jsonb NOT NULL DEFAULT '{}'::jsonb,
	
	CONSTRAINT fk_agent_id FOREIGN KEY (agent_id) REFERENCES agents(id),
	CONSTRAINT fk_rsrc_agent_id FOREIGN KEY (rsrc_agent_id) REFERENCES agents(id)
);
-- Ensure that agent's cannot have duplicate resources with the same code_name.
CREATE UNIQUE INDEX IF NOT EXISTS idx_res_agent_code ON resources(code_name, agent_id);
-- Ensure that resources are defined uniquely by the agent and the resource owner.
CREATE UNIQUE INDEX IF NOT EXISTS idx_res_agent_rsrc_agent_id ON resources(agent_id, rsrc_agent_id);

-- MEMORY PREDICATES
CREATE TABLE IF NOT EXISTS memory_predicates (
	id varchar(64) NOT NULL DEFAULT CONCAT('pred_', ksuid_pgcrypto()) PRIMARY KEY,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	name varchar(32) NOT NULL,
	description jsonb NOT NULL DEFAULT '{}'::jsonb
);
-- Ensure that memory_predicates are uniquely named
CREATE UNIQUE INDEX IF NOT EXISTS idx_pred_name ON memory_predicates(name);

-- MEMORIES
CREATE TYPE memory_type AS ENUM (
	'chat',
	'event',
	'thought',
	'whisper'
);
CREATE TABLE IF NOT EXISTS memories (
	id varchar(64) NOT NULL DEFAULT CONCAT('mem_', ksuid_pgcrypto()) PRIMARY KEY,
	agent_id varchar(64) NOT NULL,
	created_at timestamptz NOT NULL DEFAULT now(),
	updated_at timestamptz NOT NULL DEFAULT now(),
	type memory_type NOT NULL,
	poignancy_val INT NOT NULL DEFAULT 0,
	reward_val INT NOT NULL DEFAULT 0,
	subject TEXT NOT NULL DEFAULT '',
	subject_id varchar(64),
	predicate TEXT NOT NULL DEFAULT '',
	predicate_id varchar(64),
	object TEXT NOT NULL DEFAULT '',
	embedding_id varchar(64),
	context jsonb NOT NULL DEFAULT '{}'::jsonb,
	description TEXT NOT NULL DEFAULT '',
	keywords jsonb NOT NULL DEFAULT '{}'::jsonb,
	evidence jsonb NOT NULL DEFAULT '{}'::jsonb,
	start_depth INT NOT NULL DEFAULT 0,
	relative_depth_expiration INT NOT NULL DEFAULT 0,
	
	CONSTRAINT fk_agent_id FOREIGN KEY (agent_id) REFERENCES agents(id),
	CONSTRAINT fk_predicate_id FOREIGN KEY (predicate_id) REFERENCES memory_predicates(id)
);
-- Ensure that agent's cannot have duplicate memories.
CREATE UNIQUE INDEX IF NOT EXISTS idx_mem_agent_embedding ON memories(agent_id, embedding_id);
