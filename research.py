from agent.base import BaseAgent

class ResearchAgent(BaseAgent):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def start(self):
        raise NotImplementedError
    
    def pause(self):
        raise NotImplementedError
    
    def stop(self):
        raise NotImplementedError
    
    def prepare_turn(self):
        raise NotImplementedError
    
    def do_turn(self):
        raise NotImplementedError
    
    def end_turn(self):
        raise NotImplementedError
    
