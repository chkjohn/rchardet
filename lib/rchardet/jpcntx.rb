######################## BEGIN LICENSE BLOCK ########################
# The Original Code is Mozilla Communicator client code.
#
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 1998
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Jeff Hodges - port to Ruby
#   Mark Pilgrim - port to Python
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301  USA
######################### END LICENSE BLOCK #########################

module CharDet
  NUM_OF_CATEGORY = 6
  DONT_KNOW = -1
  ENOUGH_REL_THRESHOLD = 100
  MAX_REL_THRESHOLD = 1000
  MINIMUM_DATA_THRESHOLD = 4

  # This is hiragana 2-char sequence table, the number in each cell represents its frequency category
  JP2_CHAR_CONTEXT = [
    [0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1].freeze,
    [2,4,0,4,0,3,0,4,0,3,4,4,4,2,4,3,3,4,3,2,3,3,4,2,3,3,3,2,4,1,4,3,3,1,5,4,3,4,3,4,3,5,3,0,3,5,4,2,0,3,1,0,3,3,0,3,3,0,1,1,0,4,3,0,3,3,0,4,0,2,0,3,5,5,5,5,4,0,4,1,0,3,4].freeze,
    [0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2].freeze,
    [0,4,0,5,0,5,0,4,0,4,5,4,4,3,5,3,5,1,5,3,4,3,4,4,3,4,3,3,4,3,5,4,4,3,5,5,3,5,5,5,3,5,5,3,4,5,5,3,1,3,2,0,3,4,0,4,2,0,4,2,1,5,3,2,3,5,0,4,0,2,0,5,4,4,5,4,5,0,4,0,0,4,4].freeze,
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].freeze,
    [0,3,0,4,0,3,0,3,0,4,5,4,3,3,3,3,4,3,5,4,4,3,5,4,4,3,4,3,4,4,4,4,5,3,4,4,3,4,5,5,4,5,5,1,4,5,4,3,0,3,3,1,3,3,0,4,4,0,3,3,1,5,3,3,3,5,0,4,0,3,0,4,4,3,4,3,3,0,4,1,1,3,4].freeze,
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].freeze,
    [0,4,0,3,0,3,0,4,0,3,4,4,3,2,2,1,2,1,3,1,3,3,3,3,3,4,3,1,3,3,5,3,3,0,4,3,0,5,4,3,3,5,4,4,3,4,4,5,0,1,2,0,1,2,0,2,2,0,1,0,0,5,2,2,1,4,0,3,0,1,0,4,4,3,5,4,3,0,2,1,0,4,3].freeze,
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].freeze,
    [0,3,0,5,0,4,0,2,1,4,4,2,4,1,4,2,4,2,4,3,3,3,4,3,3,3,3,1,4,2,3,3,3,1,4,4,1,1,1,4,3,3,2,0,2,4,3,2,0,3,3,0,3,1,1,0,0,0,3,3,0,4,2,2,3,4,0,4,0,3,0,4,4,5,3,4,4,0,3,0,0,1,4].freeze,
    [1,4,0,4,0,4,0,4,0,3,5,4,4,3,4,3,5,4,3,3,4,3,5,4,4,4,4,3,4,2,4,3,3,1,5,4,3,2,4,5,4,5,5,4,4,5,4,4,0,3,2,2,3,3,0,4,3,1,3,2,1,4,3,3,4,5,0,3,0,2,0,4,5,5,4,5,4,0,4,0,0,5,4].freeze,
    [0,5,0,5,0,4,0,3,0,4,4,3,4,3,3,3,4,0,4,4,4,3,4,3,4,3,3,1,4,2,4,3,4,0,5,4,1,4,5,4,4,5,3,2,4,3,4,3,2,4,1,3,3,3,2,3,2,0,4,3,3,4,3,3,3,4,0,4,0,3,0,4,5,4,4,4,3,0,4,1,0,1,3].freeze,
    [0,3,1,4,0,3,0,2,0,3,4,4,3,1,4,2,3,3,4,3,4,3,4,3,4,4,3,2,3,1,5,4,4,1,4,4,3,5,4,4,3,5,5,4,3,4,4,3,1,2,3,1,2,2,0,3,2,0,3,1,0,5,3,3,3,4,3,3,3,3,4,4,4,4,5,4,2,0,3,3,2,4,3].freeze,
    [0,2,0,3,0,1,0,1,0,0,3,2,0,0,2,0,1,0,2,1,3,3,3,1,2,3,1,0,1,0,4,2,1,1,3,3,0,4,3,3,1,4,3,3,0,3,3,2,0,0,0,0,1,0,0,2,0,0,0,0,0,4,1,0,2,3,2,2,2,1,3,3,3,4,4,3,2,0,3,1,0,3,3].freeze,
    [0,4,0,4,0,3,0,3,0,4,4,4,3,3,3,3,3,3,4,3,4,2,4,3,4,3,3,2,4,3,4,5,4,1,4,5,3,5,4,5,3,5,4,0,3,5,5,3,1,3,3,2,2,3,0,3,4,1,3,3,2,4,3,3,3,4,0,4,0,3,0,4,5,4,4,5,3,0,4,1,0,3,4].freeze,
    [0,2,0,3,0,3,0,0,0,2,2,2,1,0,1,0,0,0,3,0,3,0,3,0,1,3,1,0,3,1,3,3,3,1,3,3,3,0,1,3,1,3,4,0,0,3,1,1,0,3,2,0,0,0,0,1,3,0,1,0,0,3,3,2,0,3,0,0,0,0,0,3,4,3,4,3,3,0,3,0,0,2,3].freeze,
    [2,3,0,3,0,2,0,1,0,3,3,4,3,1,3,1,1,1,3,1,4,3,4,3,3,3,0,0,3,1,5,4,3,1,4,3,2,5,5,4,4,4,4,3,3,4,4,4,0,2,1,1,3,2,0,1,2,0,0,1,0,4,1,3,3,3,0,3,0,1,0,4,4,4,5,5,3,0,2,0,0,4,4].freeze,
    [0,2,0,1,0,3,1,3,0,2,3,3,3,0,3,1,0,0,3,0,3,2,3,1,3,2,1,1,0,0,4,2,1,0,2,3,1,4,3,2,0,4,4,3,1,3,1,3,0,1,0,0,1,0,0,0,1,0,0,0,0,4,1,1,1,2,0,3,0,0,0,3,4,2,4,3,2,0,1,0,0,3,3].freeze,
    [0,1,0,4,0,5,0,4,0,2,4,4,2,3,3,2,3,3,5,3,3,3,4,3,4,2,3,0,4,3,3,3,4,1,4,3,2,1,5,5,3,4,5,1,3,5,4,2,0,3,3,0,1,3,0,4,2,0,1,3,1,4,3,3,3,3,0,3,0,1,0,3,4,4,4,5,5,0,3,0,1,4,5].freeze,
    [0,2,0,3,0,3,0,0,0,2,3,1,3,0,4,0,1,1,3,0,3,4,3,2,3,1,0,3,3,2,3,1,3,0,2,3,0,2,1,4,1,2,2,0,0,3,3,0,0,2,0,0,0,1,0,0,0,0,2,2,0,3,2,1,3,3,0,2,0,2,0,0,3,3,1,2,4,0,3,0,2,2,3].freeze,
    [2,4,0,5,0,4,0,4,0,2,4,4,4,3,4,3,3,3,1,2,4,3,4,3,4,4,5,0,3,3,3,3,2,0,4,3,1,4,3,4,1,4,4,3,3,4,4,3,1,2,3,0,4,2,0,4,1,0,3,3,0,4,3,3,3,4,0,4,0,2,0,3,5,3,4,5,2,0,3,0,0,4,5].freeze,
    [0,3,0,4,0,1,0,1,0,1,3,2,2,1,3,0,3,0,2,0,2,0,3,0,2,0,0,0,1,0,1,1,0,0,3,1,0,0,0,4,0,3,1,0,2,1,3,0,0,0,0,0,0,3,0,0,0,0,0,0,0,4,2,2,3,1,0,3,0,0,0,1,4,4,4,3,0,0,4,0,0,1,4].freeze,
    [1,4,1,5,0,3,0,3,0,4,5,4,4,3,5,3,3,4,4,3,4,1,3,3,3,3,2,1,4,1,5,4,3,1,4,4,3,5,4,4,3,5,4,3,3,4,4,4,0,3,3,1,2,3,0,3,1,0,3,3,0,5,4,4,4,4,4,4,3,3,5,4,4,3,3,5,4,0,3,2,0,4,4].freeze,
    [0,2,0,3,0,1,0,0,0,1,3,3,3,2,4,1,3,0,3,1,3,0,2,2,1,1,0,0,2,0,4,3,1,0,4,3,0,4,4,4,1,4,3,1,1,3,3,1,0,2,0,0,1,3,0,0,0,0,2,0,0,4,3,2,4,3,5,4,3,3,3,4,3,3,4,3,3,0,2,1,0,3,3].freeze,
    [0,2,0,4,0,3,0,2,0,2,5,5,3,4,4,4,4,1,4,3,3,0,4,3,4,3,1,3,3,2,4,3,0,3,4,3,0,3,4,4,2,4,4,0,4,5,3,3,2,2,1,1,1,2,0,1,5,0,3,3,2,4,3,3,3,4,0,3,0,2,0,4,4,3,5,5,0,0,3,0,2,3,3].freeze,
    [0,3,0,4,0,3,0,1,0,3,4,3,3,1,3,3,3,0,3,1,3,0,4,3,3,1,1,0,3,0,3,3,0,0,4,4,0,1,5,4,3,3,5,0,3,3,4,3,0,2,0,1,1,1,0,1,3,0,1,2,1,3,3,2,3,3,0,3,0,1,0,1,3,3,4,4,1,0,1,2,2,1,3].freeze,
    [0,1,0,4,0,4,0,3,0,1,3,3,3,2,3,1,1,0,3,0,3,3,4,3,2,4,2,0,1,0,4,3,2,0,4,3,0,5,3,3,2,4,4,4,3,3,3,4,0,1,3,0,0,1,0,0,1,0,0,0,0,4,2,3,3,3,0,3,0,0,0,4,4,4,5,3,2,0,3,3,0,3,5].freeze,
    [0,2,0,3,0,0,0,3,0,1,3,0,2,0,0,0,1,0,3,1,1,3,3,0,0,3,0,0,3,0,2,3,1,0,3,1,0,3,3,2,0,4,2,2,0,2,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,2,1,2,0,1,0,1,0,0,0,1,3,1,2,0,0,0,1,0,0,1,4].freeze,
    [0,3,0,3,0,5,0,1,0,2,4,3,1,3,3,2,1,1,5,2,1,0,5,1,2,0,0,0,3,3,2,2,3,2,4,3,0,0,3,3,1,3,3,0,2,5,3,4,0,3,3,0,1,2,0,2,2,0,3,2,0,2,2,3,3,3,0,2,0,1,0,3,4,4,2,5,4,0,3,0,0,3,5].freeze,
    [0,3,0,3,0,3,0,1,0,3,3,3,3,0,3,0,2,0,2,1,1,0,2,0,1,0,0,0,2,1,0,0,1,0,3,2,0,0,3,3,1,2,3,1,0,3,3,0,0,1,0,0,0,0,0,2,0,0,0,0,0,2,3,1,2,3,0,3,0,1,0,3,2,1,0,4,3,0,1,1,0,3,3].freeze,
    [0,4,0,5,0,3,0,3,0,4,5,5,4,3,5,3,4,3,5,3,3,2,5,3,4,4,4,3,4,3,4,5,5,3,4,4,3,4,4,5,4,4,4,3,4,5,5,4,2,3,4,2,3,4,0,3,3,1,4,3,2,4,3,3,5,5,0,3,0,3,0,5,5,5,5,4,4,0,4,0,1,4,4].freeze,
    [0,4,0,4,0,3,0,3,0,3,5,4,4,2,3,2,5,1,3,2,5,1,4,2,3,2,3,3,4,3,3,3,3,2,5,4,1,3,3,5,3,4,4,0,4,4,3,1,1,3,1,0,2,3,0,2,3,0,3,0,0,4,3,1,3,4,0,3,0,2,0,4,4,4,3,4,5,0,4,0,0,3,4].freeze,
    [0,3,0,3,0,3,1,2,0,3,4,4,3,3,3,0,2,2,4,3,3,1,3,3,3,1,1,0,3,1,4,3,2,3,4,4,2,4,4,4,3,4,4,3,2,4,4,3,1,3,3,1,3,3,0,4,1,0,2,2,1,4,3,2,3,3,5,4,3,3,5,4,4,3,3,0,4,0,3,2,2,4,4].freeze,
    [0,2,0,1,0,0,0,0,0,1,2,1,3,0,0,0,0,0,2,0,1,2,1,0,0,1,0,0,0,0,3,0,0,1,0,1,1,3,1,0,0,0,1,1,0,1,1,0,0,0,0,0,2,0,0,0,0,0,0,0,0,1,1,2,2,0,3,4,0,0,0,1,1,0,0,1,0,0,0,0,0,1,1].freeze,
    [0,1,0,0,0,1,0,0,0,0,4,0,4,1,4,0,3,0,4,0,3,0,4,0,3,0,3,0,4,1,5,1,4,0,0,3,0,5,0,5,2,0,1,0,0,0,2,1,4,0,1,3,0,0,3,0,0,3,1,1,4,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0].freeze,
    [1,4,0,5,0,3,0,2,0,3,5,4,4,3,4,3,5,3,4,3,3,0,4,3,3,3,3,3,3,2,4,4,3,1,3,4,4,5,4,4,3,4,4,1,3,5,4,3,3,3,1,2,2,3,3,1,3,1,3,3,3,5,3,3,4,5,0,3,0,3,0,3,4,3,4,4,3,0,3,0,2,4,3].freeze,
    [0,1,0,4,0,0,0,0,0,1,4,0,4,1,4,2,4,0,3,0,1,0,1,0,0,0,0,0,2,0,3,1,1,1,0,3,0,0,0,1,2,1,0,0,1,1,1,1,0,1,0,0,0,1,0,0,3,0,0,0,0,3,2,0,2,2,0,1,0,0,0,2,3,2,3,3,0,0,0,0,2,1,0].freeze,
    [0,5,1,5,0,3,0,3,0,5,4,4,5,1,5,3,3,0,4,3,4,3,5,3,4,3,3,2,4,3,4,3,3,0,3,3,1,4,4,3,4,4,4,3,4,5,5,3,2,3,1,1,3,3,1,3,1,1,3,3,2,4,5,3,3,5,0,4,0,3,0,4,4,3,5,3,3,0,3,4,0,4,3].freeze,
    [0,5,0,5,0,3,0,2,0,4,4,3,5,2,4,3,3,3,4,4,4,3,5,3,5,3,3,1,4,0,4,3,3,0,3,3,0,4,4,4,4,5,4,3,3,5,5,3,2,3,1,2,3,2,0,1,0,0,3,2,2,4,4,3,1,5,0,4,0,3,0,4,3,1,3,2,1,0,3,3,0,3,3].freeze,
    [0,4,0,5,0,5,0,4,0,4,5,5,5,3,4,3,3,2,5,4,4,3,5,3,5,3,4,0,4,3,4,4,3,2,4,4,3,4,5,4,4,5,5,0,3,5,5,4,1,3,3,2,3,3,1,3,1,0,4,3,1,4,4,3,4,5,0,4,0,2,0,4,3,4,4,3,3,0,4,0,0,5,5].freeze,
    [0,4,0,4,0,5,0,1,1,3,3,4,4,3,4,1,3,0,5,1,3,0,3,1,3,1,1,0,3,0,3,3,4,0,4,3,0,4,4,4,3,4,4,0,3,5,4,1,0,3,0,0,2,3,0,3,1,0,3,1,0,3,2,1,3,5,0,3,0,1,0,3,2,3,3,4,4,0,2,2,0,4,4].freeze,
    [2,4,0,5,0,4,0,3,0,4,5,5,4,3,5,3,5,3,5,3,5,2,5,3,4,3,3,4,3,4,5,3,2,1,5,4,3,2,3,4,5,3,4,1,2,5,4,3,0,3,3,0,3,2,0,2,3,0,4,1,0,3,4,3,3,5,0,3,0,1,0,4,5,5,5,4,3,0,4,2,0,3,5].freeze,
    [0,5,0,4,0,4,0,2,0,5,4,3,4,3,4,3,3,3,4,3,4,2,5,3,5,3,4,1,4,3,4,4,4,0,3,5,0,4,4,4,4,5,3,1,3,4,5,3,3,3,3,3,3,3,0,2,2,0,3,3,2,4,3,3,3,5,3,4,1,3,3,5,3,2,0,0,0,0,4,3,1,3,3].freeze,
    [0,1,0,3,0,3,0,1,0,1,3,3,3,2,3,3,3,0,3,0,0,0,3,1,3,0,0,0,2,2,2,3,0,0,3,2,0,1,2,4,1,3,3,0,0,3,3,3,0,1,0,0,2,1,0,0,3,0,3,1,0,3,0,0,1,3,0,2,0,1,0,3,3,1,3,3,0,0,1,1,0,3,3].freeze,
    [0,2,0,3,0,2,1,4,0,2,2,3,1,1,3,1,1,0,2,0,3,1,2,3,1,3,0,0,1,0,4,3,2,3,3,3,1,4,2,3,3,3,3,1,0,3,1,4,0,1,1,0,1,2,0,1,1,0,1,1,0,3,1,3,2,2,0,1,0,0,0,2,3,3,3,1,0,0,0,0,0,2,3].freeze,
    [0,5,0,4,0,5,0,2,0,4,5,5,3,3,4,3,3,1,5,4,4,2,4,4,4,3,4,2,4,3,5,5,4,3,3,4,3,3,5,5,4,5,5,1,3,4,5,3,1,4,3,1,3,3,0,3,3,1,4,3,1,4,5,3,3,5,0,4,0,3,0,5,3,3,1,4,3,0,4,0,1,5,3].freeze,
    [0,5,0,5,0,4,0,2,0,4,4,3,4,3,3,3,3,3,5,4,4,4,4,4,4,5,3,3,5,2,4,4,4,3,4,4,3,3,4,4,5,5,3,3,4,3,4,3,3,4,3,3,3,3,1,2,2,1,4,3,3,5,4,4,3,4,0,4,0,3,0,4,4,4,4,4,1,0,4,2,0,2,4].freeze,
    [0,4,0,4,0,3,0,1,0,3,5,2,3,0,3,0,2,1,4,2,3,3,4,1,4,3,3,2,4,1,3,3,3,0,3,3,0,0,3,3,3,5,3,3,3,3,3,2,0,2,0,0,2,0,0,2,0,0,1,0,0,3,1,2,2,3,0,3,0,2,0,4,4,3,3,4,1,0,3,0,0,2,4].freeze,
    [0,0,0,4,0,0,0,0,0,0,1,0,1,0,2,0,0,0,0,0,1,0,2,0,1,0,0,0,0,0,3,1,3,0,3,2,0,0,0,1,0,3,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,4,0,2,0,0,0,0,0,0,2].freeze,
    [0,2,1,3,0,2,0,2,0,3,3,3,3,1,3,1,3,3,3,3,3,3,4,2,2,1,2,1,4,0,4,3,1,3,3,3,2,4,3,5,4,3,3,3,3,3,3,3,0,1,3,0,2,0,0,1,0,0,1,0,0,4,2,0,2,3,0,3,3,0,3,3,4,2,3,1,4,0,1,2,0,2,3].freeze,
    [0,3,0,3,0,1,0,3,0,2,3,3,3,0,3,1,2,0,3,3,2,3,3,2,3,2,3,1,3,0,4,3,2,0,3,3,1,4,3,3,2,3,4,3,1,3,3,1,1,0,1,1,0,1,0,1,0,1,0,0,0,4,1,1,0,3,0,3,1,0,2,3,3,3,3,3,1,0,0,2,0,3,3].freeze,
    [0,0,0,0,0,0,0,0,0,0,3,0,2,0,3,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,3,0,3,0,3,1,0,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,2,0,2,3,0,0,0,0,0,0,0,0,3].freeze,
    [0,2,0,3,1,3,0,3,0,2,3,3,3,1,3,1,3,1,3,1,3,3,3,1,3,0,2,3,1,1,4,3,3,2,3,3,1,2,2,4,1,3,3,0,1,4,2,3,0,1,3,0,3,0,0,1,3,0,2,0,0,3,3,2,1,3,0,3,0,2,0,3,4,4,4,3,1,0,3,0,0,3,3].freeze,
    [0,2,0,1,0,2,0,0,0,1,3,2,2,1,3,0,1,1,3,0,3,2,3,1,2,0,2,0,1,1,3,3,3,0,3,3,1,1,2,3,2,3,3,1,2,3,2,0,0,1,0,0,0,0,0,0,3,0,1,0,0,2,1,2,1,3,0,3,0,0,0,3,4,4,4,3,2,0,2,0,0,2,4].freeze,
    [0,0,0,1,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,2,2,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,3,1,0,0,0,0,0,0,0,3].freeze,
    [0,3,0,3,0,2,0,3,0,3,3,3,2,3,2,2,2,0,3,1,3,3,3,2,3,3,0,0,3,0,3,2,2,0,2,3,1,4,3,4,3,3,2,3,1,5,4,4,0,3,1,2,1,3,0,3,1,1,2,0,2,3,1,3,1,3,0,3,0,1,0,3,3,4,4,2,1,0,2,1,0,2,4].freeze,
    [0,1,0,3,0,1,0,2,0,1,4,2,5,1,4,0,2,0,2,1,3,1,4,0,2,1,0,0,2,1,4,1,1,0,3,3,0,5,1,3,2,3,3,1,0,3,2,3,0,1,0,0,0,0,0,0,1,0,0,0,0,4,0,1,0,3,0,2,0,1,0,3,3,3,4,3,3,0,0,0,0,2,3].freeze,
    [0,0,0,1,0,0,0,0,0,0,2,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,0,0,1,0,0,0,0,0,3].freeze,
    [0,1,0,3,0,4,0,3,0,2,4,3,1,0,3,2,2,1,3,1,2,2,3,1,1,1,2,1,3,0,1,2,0,1,3,2,1,3,0,5,5,1,0,0,1,3,2,1,0,3,0,0,1,0,0,0,0,0,3,4,0,1,1,1,3,2,0,2,0,1,0,2,3,3,1,2,3,0,1,0,1,0,4].freeze,
    [0,0,0,1,0,3,0,3,0,2,2,1,0,0,4,0,3,0,3,1,3,0,3,0,3,0,1,0,3,0,3,1,3,0,3,3,0,0,1,2,1,1,1,0,1,2,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,2,2,1,2,0,0,2,0,0,0,0,2,3,3,3,3,0,0,0,0,1,4].freeze,
    [0,0,0,3,0,3,0,0,0,0,3,1,1,0,3,0,1,0,2,0,1,0,0,0,0,0,0,0,1,0,3,0,2,0,2,3,0,0,2,2,3,1,2,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,2,0,0,0,0,2,3].freeze,
    [2,4,0,5,0,5,0,4,0,3,4,3,3,3,4,3,3,3,4,3,4,4,5,4,5,5,5,2,3,0,5,5,4,1,5,4,3,1,5,4,3,4,4,3,3,4,3,3,0,3,2,0,2,3,0,3,0,0,3,3,0,5,3,2,3,3,0,3,0,3,0,3,4,5,4,5,3,0,4,3,0,3,4].freeze,
    [0,3,0,3,0,3,0,3,0,3,3,4,3,2,3,2,3,0,4,3,3,3,3,3,3,3,3,0,3,2,4,3,3,1,3,4,3,4,4,4,3,4,4,3,2,4,4,1,0,2,0,0,1,1,0,2,0,0,3,1,0,5,3,2,1,3,0,3,0,1,2,4,3,2,4,3,3,0,3,2,0,4,4].freeze,
    [0,3,0,3,0,1,0,0,0,1,4,3,3,2,3,1,3,1,4,2,3,2,4,2,3,4,3,0,2,2,3,3,3,0,3,3,3,0,3,4,1,3,3,0,3,4,3,3,0,1,1,0,1,0,0,0,4,0,3,0,0,3,1,2,1,3,0,4,0,1,0,4,3,3,4,3,3,0,2,0,0,3,3].freeze,
    [0,3,0,4,0,1,0,3,0,3,4,3,3,0,3,3,3,1,3,1,3,3,4,3,3,3,0,0,3,1,5,3,3,1,3,3,2,5,4,3,3,4,5,3,2,5,3,4,0,1,0,0,0,0,0,2,0,0,1,1,0,4,2,2,1,3,0,3,0,2,0,4,4,3,5,3,2,0,1,1,0,3,4].freeze,
    [0,5,0,4,0,5,0,2,0,4,4,3,3,2,3,3,3,1,4,3,4,1,5,3,4,3,4,0,4,2,4,3,4,1,5,4,0,4,4,4,4,5,4,1,3,5,4,2,1,4,1,1,3,2,0,3,1,0,3,2,1,4,3,3,3,4,0,4,0,3,0,4,4,4,3,3,3,0,4,2,0,3,4].freeze,
    [1,4,0,4,0,3,0,1,0,3,3,3,1,1,3,3,2,2,3,3,1,0,3,2,2,1,2,0,3,1,2,1,2,0,3,2,0,2,2,3,3,4,3,0,3,3,1,2,0,1,1,3,1,2,0,0,3,0,1,1,0,3,2,2,3,3,0,3,0,0,0,2,3,3,4,3,3,0,1,0,0,1,4].freeze,
    [0,4,0,4,0,4,0,0,0,3,4,4,3,1,4,2,3,2,3,3,3,1,4,3,4,0,3,0,4,2,3,3,2,2,5,4,2,1,3,4,3,4,3,1,3,3,4,2,0,2,1,0,3,3,0,0,2,0,3,1,0,4,4,3,4,3,0,4,0,1,0,2,4,4,4,4,4,0,3,2,0,3,3].freeze,
    [0,0,0,1,0,4,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,3,2,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,2].freeze,
    [0,2,0,3,0,4,0,4,0,1,3,3,3,0,4,0,2,1,2,1,1,1,2,0,3,1,1,0,1,0,3,1,0,0,3,3,2,0,1,1,0,0,0,0,0,1,0,2,0,2,2,0,3,1,0,0,1,0,1,1,0,1,2,0,3,0,0,0,0,1,0,0,3,3,4,3,1,0,1,0,3,0,2].freeze,
    [0,0,0,3,0,5,0,0,0,0,1,0,2,0,3,1,0,1,3,0,0,0,2,0,0,0,1,0,0,0,1,1,0,0,4,0,0,0,2,3,0,1,4,1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,1,0,0,0,0,0,0,0,2,0,0,3,0,0,0,0,0,3].freeze,
    [0,2,0,5,0,5,0,1,0,2,4,3,3,2,5,1,3,2,3,3,3,0,4,1,2,0,3,0,4,0,2,2,1,1,5,3,0,0,1,4,2,3,2,0,3,3,3,2,0,2,4,1,1,2,0,1,1,0,3,1,0,1,3,1,2,3,0,2,0,0,0,1,3,5,4,4,4,0,3,0,0,1,3].freeze,
    [0,4,0,5,0,4,0,4,0,4,5,4,3,3,4,3,3,3,4,3,4,4,5,3,4,5,4,2,4,2,3,4,3,1,4,4,1,3,5,4,4,5,5,4,4,5,5,5,2,3,3,1,4,3,1,3,3,0,3,3,1,4,3,4,4,4,0,3,0,4,0,3,3,4,4,5,0,0,4,3,0,4,5].freeze,
    [0,4,0,4,0,3,0,3,0,3,4,4,4,3,3,2,4,3,4,3,4,3,5,3,4,3,2,1,4,2,4,4,3,1,3,4,2,4,5,5,3,4,5,4,1,5,4,3,0,3,2,2,3,2,1,3,1,0,3,3,3,5,3,3,3,5,4,4,2,3,3,4,3,3,3,2,1,0,3,2,1,4,3].freeze,
    [0,4,0,5,0,4,0,3,0,3,5,5,3,2,4,3,4,0,5,4,4,1,4,4,4,3,3,3,4,3,5,5,2,3,3,4,1,2,5,5,3,5,5,2,3,5,5,4,0,3,2,0,3,3,1,1,5,1,4,1,0,4,3,2,3,5,0,4,0,3,0,5,4,3,4,3,0,0,4,1,0,4,4].freeze,
    [1,3,0,4,0,2,0,2,0,2,5,5,3,3,3,3,3,0,4,2,3,4,4,4,3,4,0,0,3,4,5,4,3,3,3,3,2,5,5,4,5,5,5,4,3,5,5,5,1,3,1,0,1,0,0,3,2,0,4,2,0,5,2,3,2,4,1,3,0,3,0,4,5,4,5,4,3,0,4,2,0,5,4].freeze,
    [0,3,0,4,0,5,0,3,0,3,4,4,3,2,3,2,3,3,3,3,3,2,4,3,3,2,2,0,3,3,3,3,3,1,3,3,3,0,4,4,3,4,4,1,1,4,4,2,0,3,1,0,1,1,0,4,1,0,2,3,1,3,3,1,3,4,0,3,0,1,0,3,1,3,0,0,1,0,2,0,0,4,4].freeze,
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0].freeze,
    [0,3,0,3,0,2,0,3,0,1,5,4,3,3,3,1,4,2,1,2,3,4,4,2,4,4,5,0,3,1,4,3,4,0,4,3,3,3,2,3,2,5,3,4,3,2,2,3,0,0,3,0,2,1,0,1,2,0,0,0,0,2,1,1,3,1,0,2,0,4,0,3,4,4,4,5,2,0,2,0,0,1,3].freeze,
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,1,0,0,1,1,0,0,0,4,2,1,1,0,1,0,3,2,0,0,3,1,1,1,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,1,0,0,0,2,0,0,0,1,4,0,4,2,1,0,0,0,0,0,1].freeze,
    [0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,0,0,0,3,1,0,0,0,2,0,2,1,0,0,1,2,1,0,1,1,0,0,3,0,0,0,0,0,0,0,0,0,0,0,1,3,1,0,0,0,0,0,1,0,0,2,1,0,0,0,0,0,0,0,0,2].freeze,
    [0,4,0,4,0,4,0,3,0,4,4,3,4,2,4,3,2,0,4,4,4,3,5,3,5,3,3,2,4,2,4,3,4,3,1,4,0,2,3,4,4,4,3,3,3,4,4,4,3,4,1,3,4,3,2,1,2,1,3,3,3,4,4,3,3,5,0,4,0,3,0,4,3,3,3,2,1,0,3,0,0,3,3].freeze,
    [0,4,0,3,0,3,0,3,0,3,5,5,3,3,3,3,4,3,4,3,3,3,4,4,4,3,3,3,3,4,3,5,3,3,1,3,2,4,5,5,5,5,4,3,4,5,5,3,2,2,3,3,3,3,2,3,3,1,2,3,2,4,3,3,3,4,0,4,0,2,0,4,3,2,2,1,2,0,3,0,0,4,1].freeze,
  ].freeze

  class JapaneseContextAnalysis
    def initialize
      reset()
    end

    def reset
      @totalRel = 0 # total sequence received
      @relSample = [0] * NUM_OF_CATEGORY # category counters, each interger counts sequence in its category
      @needToSkipCharNum = 0 # if last byte in current buffer is not the last byte of a character, we need to know how many bytes to skip in next buffer
      @lastCharOrder = -1 # The order of previous char
      @done = false # If this flag is set to constants.True, detection is done and conclusion has been made
    end

    def feed(aBuf, aLen)
      return if @done

      # The buffer we got is byte oriented, and a character may span in more than one
      # buffers. In case the last one or two byte in last buffer is not complete, we 
      # record how many byte needed to complete that character and skip these bytes here.
      # We can choose to record those bytes as well and analyse the character once it 
      # is complete, but since a character will not make much difference, by simply skipping
      # this character will simply our logic and improve performance.
      i = @needToSkipCharNum
      while i < aLen
        order, charLen = get_order(aBuf[i, 2])
        i += charLen
        if i > aLen
          @needToSkipCharNum = i - aLen
          @lastCharOrder = -1
        else
          if (order != -1) and (@lastCharOrder != -1)
            @totalRel += 1
            if @totalRel > MAX_REL_THRESHOLD
              @done = true
              break
            end
            @relSample[JP2_CHAR_CONTEXT[@lastCharOrder][order]] += 1
          end
          @lastCharOrder = order
        end
      end
    end

    def got_enough_data
      return @totalRel > ENOUGH_REL_THRESHOLD
    end

    def get_confidence
      # This is just one way to calculate confidence. It works well for me.
      if @totalRel > MINIMUM_DATA_THRESHOLD
        return (@totalRel - @relSample[0]) / @totalRel
      else
        return DONT_KNOW
      end
    end

    def get_order(aStr)
      return -1, 1
    end
  end

  class SJISContextAnalysis < JapaneseContextAnalysis
    def get_order(aStr)
      return -1, 1 if aStr.nil? || aStr == ""
      # find out current char's byte length
      first = aStr[0, 1]
      if ((first >= "\x81") and (first <= "\x9F")) or ((first >= "\xE0") and (first <= "\xFC"))
        charLen = 2
      else
        charLen = 1
      end
      # return its order if it is hiragana
      if aStr.length > 1
        second = aStr[1, 1]
        if (first == "\202") and (second >= "\x9F") and (second <= "\xF1")
          return aStr[1] - 0x9F, charLen
        end
      end
      
      return -1, charLen
    end
  end

  class EUCJPContextAnalysis < JapaneseContextAnalysis
    def get_order(aStr)
      return -1, 1 unless aStr
      # find out current char's byte length
      first = aStr[0, 1]
      if (first == "\x8E") or ((first >= "\xA1") and (first <= "\xFE"))
        charLen = 2
      elsif first == "\x8F"
        charLen = 3
      else
        charLen = 1
      end

      # return its order if it is hiragana
      if aStr.length > 1
        second = aStr[1, 1]
        if (first == "\xA4") and (second >= "\xA1") and (second <= "\xF3")
          return aStr[1] - 0xA1, charLen
        end
      end

      return -1, charLen
    end
  end
end
