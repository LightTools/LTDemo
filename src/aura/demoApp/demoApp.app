<aura:application extends="ltng:outApp">

    <aura:dependency resource="c:demoContainer" />

    <auraStorage:init name="actions"
            persistent="false"
            secure="true"
            maxSize="1024"
            defaultExpiration="900"
            defaultAutoRefreshInterval="30" />

</aura:application>