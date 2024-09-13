Config = {}

Config.UsePed = true
Config.Ped = `a_m_m_business_01`
Config.PedCoords = vec3(329.0191, -68.9329, 73.0378)
Config.PedHeading = 159.7570

Config.Job = 'lawyer'
Config.Cost = 25000

Config.EnableBlip = true
Config.LawyerBlip  = {
    {title = 'Lawyer', color = 0, sprite = 40, scale = 0.8, coords = Config.PedCoords},
}

Config.Strings = {
    titlechangename = 'Change Name',
    advokatmenu = 'Lawyer Menu',
    dialogtitle = 'Change A Citizen\'s Name',
    dialoginput1 = 'Citizen ID',
    dialoginput2 = 'First Name',
    dialoginput3 = 'Last Name',
    dialoginput4 = 'Date Of Birth',
    dialogenter = 'Enter ',
    errormsg = 'Invalid Citizen ID',
    notenoughmoney = 'You don\'t have enough money!',
    namechangesuccess = 'Name change successful!',
    namechangefail = 'Failed to update player info.'
}