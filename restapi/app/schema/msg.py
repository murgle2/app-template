from pydantic import BaseModel
from typing import List, Union


class Msg(BaseModel):
    msg: Union[int, str, List[int]]
