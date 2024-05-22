from abc import ABC, abstractmethod

class BaseAgent(ABC):
    """
    The Agent class is the base class for all agents in the system.
    Every agent must inherit from this class and implement the following methods:
    - start()
    - pause()
    - stop()
    - prepare_turn()
    - do_turn()
    - end_turn()
    Every agent must also have the following attributes:
    - title: Role of the agent.
    - job: Description of the agent's job.
    - background: Background of the agent. More human-like, for optimal Poignancy, Empathy, and Reward results.
    - process: The agent's process for executing tasks, this is tightly coupled with their `title`.
    - skills: The agent's skills for executing tasks, this is tightly coupled with their `process`.
    - resource_agents: The agent's resource agents for asking for help when executing tasks, asking permission, or asking for resources. This is tightly coupled with their `skills`.
    - perspective_bias: How large/small the agent's mindset is when thinking of solutions. This is tightly coupled with their `title` and will help set expectations for the agent's performance. CEO has the max score, while an intern has the min score.
    - collaboartion_bias: How much the agent prefers to work with others. This is tightly coupled with their `resources` and will help set expectations for much the agent will ask for help. CEO has the min score, while an intern has the max score.
    - reactivity_bias: How reactive the agent is to external stimuli. This is tightly coupled with their `skills` and will help set expectations for how quickly the agent will respond to tasks, requests for collaboration. CEO has the min score, while an intern has the max score.
    - poignancy_score: How stressed the agent is handling important tasks. This is tightly coupled with their `process` and will act as a pressure valve; over time the poignancy score rises effectively forcing the agent to conclude their last batch of important tasks before moving on to the next batch. This is a measure of how much the agent is willing to act out divergent processes before converging on a solution.
    - reward_score: How rewarded/accomplished the agent feels for completing tasks. This is also tightly coupled with their `process` and will act as a reward system; over time the reward score rises effectively rewarding the agent for completing tasks. This is a feedback score to the agent to help them understand if their convergent processes are working. It's reset as the agent starts a new batch of important tasks.
    - memory: The agent's memory for storing relevant information. This is a class that handles the agent's memory stream.
    - act: The agent's act for executing tasks. This is a class that handles the agent's actions.
    - brain: The agent's cognition for conversing with other agents, asking for help, and executing tasks. This is a class that handles the agent's cognition.
    """

    def __init__(self, *args, **kwargs):
        self.type = kwargs.get('type')
        self.title = kwargs.get("title")
        self.job = kwargs.get("job")
        self.background = kwargs.get("background")
        self.process = kwargs.get("process")
        self.skills = kwargs.get("skills")
        self.resource_agents = kwargs.get("resource_agents")
        self.perspective_bias = kwargs.get("perspective_bias") # How large/small the agent's mindset is when thinking of solutions.
        self.collaboartion_bias = kwargs.get("collaboration_bias") # How much the agent prefers to work with others.
        self.reactivity_bias = kwargs.get("reactivity_bias") # How reactive the agent is to external stimuli.
        self.poignancy_score = kwargs.get("poignancy_score") # How stressed the agent is handling important tasks.
        self.reward_score = kwargs.get("reward_score") # How rewarded/accomplished the agent feels for completing tasks.
        self.memory = kwargs.get('memory')
        self.act = kwargs.get('act')
        self.brain = kwargs.get('cognition')

    @abstractmethod
    def start(self):
        """
        Starts the agent from a Stopped state.
        Pull & Load the agent's seed from the datastore.
        - Title, Background, Skills, Job, Resources, Process
        - Instantiate the skills and assign them to the agent.
        """
        pass

    @abstractmethod
    def pause(self):
        """
        Pauses the agent from a Running state.
        """
        pass

    @abstractmethod
    def stop(self):
        """
        Stops the agent from a Running or Paused state.
        """
        pass

    @abstractmethod
    def prepare_turn(self):
        """
        Prepares the agent for the next turn; this includes
        - Retrieving the next task from the datastore.
        - Retrieving the latest relevant memories from the memory stream.
        """
        pass

    @abstractmethod
    def do_turn(self):
        """
        Executes the agent's turn.
        Given the task and memories, the agent must decide on the best course of action. Which may include:
        - Creating a plan for executing the task.
        - Debating the plan with other agents until a parity is reached.
        - Using "Resources" in case the plan isn't quickly reached.
        - Executing the plan via "Skills".
        """
        pass

    @abstractmethod
    def end_turn(self):
        """
        Ends the agent's turn.
        Updates the Tasks and Memories into the datastore and memory stream.
        """
        pass
